import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:flutter_chrome_cast/widgets/mini_controller.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/utils/cast/controller/fc_cast_controller.dart';

import '../../main.dart';

class FlutterChromeCastWidget extends StatefulWidget {
  const FlutterChromeCastWidget({super.key});

  @override
  State<FlutterChromeCastWidget> createState() => _FlutterChromeCastWidgetState();
}

class _FlutterChromeCastWidgetState extends State<FlutterChromeCastWidget> {
  final FCCast cast = Get.put(FCCast());

  @override
  void initState() {
    super.initState();
    cast.loadMedia();
  }

  @override
  void dispose() {
    GoogleCastDiscoveryManager.instance.stopDiscovery();
    GoogleCastSessionManager.instance.endSessionAndStopCasting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      topBarBgColor: Colors.transparent,
      appBartitleText: locale.value.screenCast,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<GoogleCastSession?>(
                stream: GoogleCastSessionManager.instance.currentSessionStream,
                builder: (context, snapshot) {
                  final bool isConnected = GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.ConnectionStateConnected;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isConnected ? Icons.cast_connected : Icons.cast,
                        size: 50,
                      ),
                      16.height,
                      OutlinedButton(
                        onPressed: () {
                          if (isConnected) {
                            GoogleCastSessionManager.instance.endSessionAndStopCasting();
                          } else {
                            log('------------load------------');
                            cast.loadMedia();
                          }
                        },
                        child: Text(
                          !isConnected ? "${locale.value.connectTo} ${cast.device?.friendlyName}" : "${locale.value.disconnectFrom} ${cast.device?.friendlyName}",
                          style: primaryTextStyle(color: white),
                        ),
                      )
                    ],
                  );
                },
              ).center(),
            ],
          ),
          const Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: GoogleCastMiniController(),
          )
        ],
      ),
    );
  }
}
