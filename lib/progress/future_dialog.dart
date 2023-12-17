import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'future_builder.dart';
import 'splash_art.dart';

Future<T?> showCustomAdaptiveDialog<T>({
  required BuildContext context,
  bool? barrierDismissible,
  required WidgetBuilder builder,
}) async {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible ?? true,
  );
}

Future<T?> showFutureProgressDialog<T>({
  required BuildContext context,
  required InitFuture<T> initFuture,
  String? message,
}) async {
  return showCustomAdaptiveDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AdaptiveProgressDialog<T>(
        initFuture: initFuture,
        message: message,
      );
    },
  );
}

class AdaptiveProgressDialog<T> extends StatelessWidget {
  final InitFuture<T> initFuture;
  final String? message;

  const AdaptiveProgressDialog({
    Key? key,
    required this.initFuture,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(8.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: SizedBox(
        height: 115.0,
        child: AdaptiveProgressDialogContent<T>(
          initFuture: initFuture,
        ),
      ),
    );
  }
}

class AdaptiveProgressDialogContent<T> extends StatelessWidget {
  final InitFuture<T> initFuture;

  const AdaptiveProgressDialogContent({
    required this.initFuture,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: CustomFutureBuilder<T>(
        initFuture: () async {
          try {
            var result = await initFuture();
            Navigator.of(context, rootNavigator: true).pop(result);
            return result;
          } catch (ex) {
            if (ex is DioError)
              Navigator.of(context, rootNavigator: true).pop(ex.response?.data as T?);
            rethrow;
          }
        },
        onLoading: (context) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SplashArt(),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "loading_indicator",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
        onError: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SplashArt(),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "loading_indicator",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
        onSuccess: (context, snapshot) {
          return const SplashArt();
        },
      ),
    );
  }
}
