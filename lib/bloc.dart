import 'package:flutter_bloc/flutter_bloc.dart';

class ConvertEvent {
  const ConvertEvent({required this.text});
  final String text;
}

class ConvertBloc extends Bloc<ConvertEvent, String> {
  ConvertBloc() : super('') {
    on<ConvertEvent>(_convert);
  }

  Future<void> _convert(ConvertEvent event, Emitter<String> emit) async {
    emit(_textConvert(event.text));
  }
}

String _textConvert(String input) {
  for (final keyword in translationMap.keys) {
    if (input.contains(keyword)) {
      return translationMap[keyword]!;
    }
  }
  return 'エラー：入力内容を再度確認してください。';
}

final Map<String, String> translationMap = {
  'apple': 'りんご',
  'banana': 'バナナ',
  'orange': 'みかん',
};
