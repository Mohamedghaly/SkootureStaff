import 'package:eschool_saas_staff/cubits/certificate/certificatesCubit.dart';
import 'package:eschool_saas_staff/data/models/certificateAssignment.dart';
import 'package:eschool_saas_staff/data/repositories/certificateRepository.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/htmlPrintMixin.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CertificateListContainer extends StatefulWidget {
  const CertificateListContainer({super.key});

  @override
  State<CertificateListContainer> createState() =>
      _CertificateListContainerState();
}

class _CertificateListContainerState extends State<CertificateListContainer>
    with HtmlPrintMixin<CertificateListContainer> {
  final CertificateRepository _certificateRepository = CertificateRepository();

  int _loadingCertificateId = -1;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<CertificatesCubit>().fetchCertificates();
    });
  }

  Future<void> _downloadAndPrint(
    CertificateAssignment certificate,
  ) async {
    if (_loadingCertificateId != -1) return;

    setState(() {
      _loadingCertificateId = certificate.id;
    });

    try {
      final html = await _certificateRepository.generateCertificateHtml(
        certificateTemplateId: certificate.id,
      );

      if (!mounted) return;

      await schedulePrint(
        html: html,
        fileName: 'certificate_${certificate.id}',
        jobName: 'certificate_${certificate.id}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingCertificateId = -1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildCertificateCard({
    required CertificateAssignment certificate,
    required int index,
    required int totalItems,
  }) {
    final theme = Theme.of(context);
    final isLoading = _loadingCertificateId == certificate.id;

    final title = certificate.certificateTemplate?.name.isNotEmpty == true
        ? certificate.certificateTemplate!.name
        : Utils.getTranslatedLabel(certificateKey);

    final subtitle = certificate.rollNo.isNotEmpty
        ? certificate.rollNo
        : certificate.issuedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
              )
            : null,
        trailing: GestureDetector(
          onTap: isLoading ? null : () => _downloadAndPrint(certificate),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.scaffoldBackgroundColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.download_rounded,
                    color: theme.scaffoldBackgroundColor,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateList(
    List<CertificateAssignment> certificates,
  ) {
    if (certificates.isEmpty) {
      return Center(
        child: noDataContainer(titleKey: noCertificatesFoundKey),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      itemCount: certificates.length,
      itemBuilder: (context, index) => _buildCertificateCard(
        certificate: certificates[index],
        index: index,
        totalItems: certificates.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildHiddenPrintWebView(
          useWideViewPort: true,
          onPrintDispatched: () => setState(() => _loadingCertificateId = -1),
        ),

        // Certificate list — opaque, covers the WebView.
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: BlocBuilder<CertificatesCubit, CertificatesState>(
            builder: (context, state) {
              if (state is CertificatesFetchSuccess) {
                return _buildCertificateList(
                  state.certificates,
                );
              }
              if (state is CertificatesFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context.read<CertificatesCubit>().fetchCertificates();
                    },
                  ),
                );
              }
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
