import 'dart:convert';

import 'package:matcher/matcher.dart';
import 'package:flutter_clean_architecture_tdd_course/core/error/exception.dart';
import 'package:flutter_clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'Should return NumberTriviaModel from SharedPreferences when there is one in the cache',
      () async {
        //arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));
        //act
        final result = await dataSource.getLastNumberTrivia();
        //assert
        verify(mockSharedPreferences.getString(CachedNumberTrivia));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'Should throw CacheException when there is not a cached value',
      () async {
        //arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        //act
        final call = dataSource.getLastNumberTrivia;
        //assert

        //() => call() calls the method from a higher order function
        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      },
    );
  });
}
