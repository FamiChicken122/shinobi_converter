import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:henkanki/bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      scrollBehavior: _MyCustomScrollBehavior(),
      home: BlocProvider(
        create: (_) => ConvertBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _State();
}

class _State extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final widgetHeight = screenHeight * 0.5;
        final widgetWidth = screenWidth * 0.4;
        return BlocBuilder<ConvertBloc, String>(
          builder: (context, state) {
            return Scaffold(
              body: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: widgetWidth,
                          height: widgetHeight,
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              labelText: 'テキストを入力してください',
                              border: OutlineInputBorder(gapPadding: 3.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: FloatingActionButton(
                            onPressed: _pasteFromClipboard,
                            tooltip: '貼り付け',
                            child: const Icon(Icons.content_paste),
                          ),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<ConvertBloc>().add(
                        ConvertEvent(text: _textController.text),
                      ),
                      tooltip: '変換',
                      child: const Icon(Icons.arrow_forward),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: widgetWidth,
                          height: widgetHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(color: Colors.black),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SelectableText(
                                context.read<ConvertBloc>().state,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: FloatingActionButton(
                            tooltip: 'コピー',
                            onPressed: () =>
                                Clipboard.setData(ClipboardData(text: state)),
                            child: const Icon(Icons.copy),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? clipboardData = await Clipboard.getData(
      Clipboard.kTextPlain,
    );

    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _textController.text = clipboardData.text!;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('クリップボードの内容を貼り付けました。')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('クリップボードにテキストデータがありません。')));
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
