import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../../provider/theme_provider.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final offlineColor =
    themeProvider.isDark ? Colors.redAccent.shade700 : Colors.redAccent;

    // Use a stream transformer to ensure we always get ConnectivityResult
    final connectivityStream = Connectivity().onConnectivityChanged.map((event) {
      if (event is List<ConnectivityResult>) {
        return event.isNotEmpty ? event.first : ConnectivityResult.none;
      } else {
        return event as ConnectivityResult;
      }
    });

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityStream,
      builder: (context, snapshot) {
        final result = snapshot.data ?? ConnectivityResult.none;
        final offline = result == ConnectivityResult.none;

        return Stack(
          children: [
            child,
            if (offline)
              Positioned.fill(
                child: Container(
                  color: themeProvider.isDark ? Colors.black87 : Colors.white70,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: screenWidth * 0.15,
                          color: Colors.grey,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No Internet Connection",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
