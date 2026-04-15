import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/transport/transportDashboardCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BusInfoCard extends StatelessWidget {
  const BusInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransportDashboardCubit, TransportDashboardState>(
      builder: (context, state) {
        final cubit = context.read<TransportDashboardCubit>();
        final busInfo = cubit.getBusInfo();

        return EnrollCard(
          title: Utils.getTranslatedLabel(busInfoKey),
          trailing: const SizedBox(),
          children: [
            Text(
              busInfo != null
                  ? '${Utils.getTranslatedLabel(busNoKey)}: ${busInfo.registration ?? 'N/A'}'
                  : Utils.getTranslatedLabel(notAvailableKey),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            PersonRow(
              label: Utils.getTranslatedLabel(driverKey),
              name: busInfo?.driver?.name ??
                  Utils.getTranslatedLabel(notAvailableKey),
              phone: busInfo?.driver?.phone,
              avatar: busInfo?.driver?.avatar,
              onPhoneTap: busInfo?.driver?.phone != null &&
                      busInfo!.driver!.phone!.isNotEmpty
                  ? () => Utils.launchCallLog(mobile: busInfo.driver!.phone!)
                  : null,
              onChatTap:
                  busInfo?.driver?.id != null && busInfo!.driver!.name != null
                      ? () => Get.toNamed(
                            Routes.chatScreen,
                            arguments: ChatScreen.buildArguments(
                              receiverId: busInfo.driver!.id!,
                              receiverName: busInfo.driver!.name!,
                              receiverImage: busInfo.driver!.avatar ?? '',
                            ),
                          )
                      : null,
            ),
            PersonRow(
              label: Utils.getTranslatedLabel(attenderKey),
              name: busInfo?.attender?.name ??
                  Utils.getTranslatedLabel(notAvailableKey),
              phone: busInfo?.attender?.phone,
              avatar: busInfo?.attender?.avatar,
              onPhoneTap: busInfo?.attender?.phone != null &&
                      busInfo!.attender!.phone!.isNotEmpty
                  ? () => Utils.launchCallLog(mobile: busInfo.attender!.phone!)
                  : null,
              onChatTap: busInfo?.attender?.id != null &&
                      busInfo!.attender!.name != null
                  ? () => Get.toNamed(
                        Routes.chatScreen,
                        arguments: ChatScreen.buildArguments(
                          receiverId: busInfo.attender!.id!,
                          receiverName: busInfo.attender!.name!,
                          receiverImage: busInfo.attender!.avatar ?? '',
                        ),
                      )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
