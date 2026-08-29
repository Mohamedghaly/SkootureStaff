import 'package:eschool_saas_staff/cubits/certificate/certificatesCubit.dart';
import 'package:eschool_saas_staff/data/repositories/certificateRepository.dart';
import 'package:eschool_saas_staff/ui/screens/certificate/certificateListContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen that wraps the CertificateListContainer with a Scaffold
/// and provides the CertificatesCubit.
class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider<CertificatesCubit>(
      create: (_) => CertificatesCubit(CertificateRepository()),
      child: const CertificateScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(titleKey: certificatesKey),
      body: const CertificateListContainer(),
    );
  }
}
