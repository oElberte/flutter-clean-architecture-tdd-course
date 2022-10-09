import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';
import 'bloc.dart';

const String ServerFailureMessage = 'Server failure.';
const String CacheFailureMessage = 'Cache failure.';
const String InvalidInputFailureMessage =
    'Invalid input - the number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    @required GetConcreteNumberTrivia concrete,
    @required GetRandomNumberTrivia random,
    @required this.inputConverter,
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random;

  @override
  NumberTriviaState get initialState => Empty();

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);

      //yield adds a value to the output stream of the surrounding async* function.
      yield* inputEither.fold(
        (failure) async* {
          yield Error(message: InvalidInputFailureMessage);
        },
        (integer) async* {
          yield Loading();
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));
          yield failureOrTrivia.fold(
            (failure) => Error(message: _mapFailureToMessage(failure)),
            (trivia) => Loaded(trivia: trivia),
          );
        },
      );
    } else if (event is GetTriviaForRandomNumber) {
      yield Loading();
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      yield failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (trivia) => Loaded(trivia: trivia),
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return ServerFailureMessage;
      case CacheFailure:
        return CacheFailureMessage;
      default:
        return 'Unexpected error.';
    }
  }
}
