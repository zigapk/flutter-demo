import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Liquid extends StatefulWidget {
  const Liquid({Key? key}) : super(key: key);

  @override
  _LiquidState createState() => _LiquidState();
}

class _LiquidState extends State<Liquid> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'),
  );
  bool get isPlaying => _controller?.isActive ?? false;

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _level;

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/rive/liquid.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        var controller =
            StateMachineController.fromArtboard(artboard, 'State Machine');
        if (controller != null) {
          artboard.addController(controller);
          _level = controller.findInput('Level');
        }
        setState(() => _riveArtboard = artboard);
      },
    );

    _channel.stream.listen((event) {
      setState(() {
        _level!.value = double.parse(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
        ? const SizedBox()
        : Stack(
            children: [
              Positioned.fill(
                  child: Rive(
                fit: BoxFit.cover,
                artboard: _riveArtboard!,
              )),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Slider(
                  value: _level!.value,
                  min: 0,
                  max: 100,
                  label: _level!.value.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _sendMessage(value.toString());
                    });
                  },
                ),
              ),
            ],
          );
  }

  void _sendMessage(message) {
    _channel.sink.add(message);
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
