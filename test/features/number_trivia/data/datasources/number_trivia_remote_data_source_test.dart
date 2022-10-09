import 'dart:convert';

import 'package:flutter_clean_architecture_tdd_course/core/error/exception.dart';
import 'package:flutter_clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  void setUpMockHttpClientWith({
    @required String response,
    @required int code,
  }) {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(response, code));
  }

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);

    //Arrange with success everytime the user don't call 'setUpMockHttpClientWith()'
    setUpMockHttpClientWith(response: fixture('trivia.json'), code: 200);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''Should perform a GET request on a URL with number
        being the endpoint and with appl/json header''',
      () async {
        //act
        dataSource.getConcreteNumberTrivia(tNumber);
        //assert
        verify(
          mockHttpClient.get(
            'http://numbersapi.com/$tNumber',
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'Should return NumberTrivia when the response code is 200 (success)',
      () async {
        //act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        //assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'Should throw a ServerException when the response is 404 or other',
      () async {
        //arrange
        setUpMockHttpClientWith(response: 'Something went wrong', code: 404);
        //act
        final call = dataSource.getConcreteNumberTrivia;
        //assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
