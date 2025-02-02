import 'package:signals_core/signals_core.dart';
import 'package:test/test.dart';

void main() {
  SignalsObserver.instance = null;
  group('AsyncState', () {
    test('AsyncData', () {
      final s = AsyncState<int>.data(0);
      expect(s.isLoading, false);
      expect(s.hasError, false);
      expect(s.hasValue, true);
      expect(s.requireValue, 0);
      expect(s.value, 0);
      expect(s.error, null);
      expect(s.stackTrace, null);
      expect(s.isRefreshing, false);
      expect(s.isReloading, false);
    });

    test('AsyncError', () {
      final s = AsyncState<int>.error('error');
      expect(s.isLoading, false);
      expect(s.hasError, true);
      expect(s.hasValue, false);
      expect(s.value, null);
      expect(s.error, 'error');
      expect(s.stackTrace != null, true);
      expect(s.isRefreshing, false);
      expect(s.isReloading, false);
    });

    test('AsyncLoading', () {
      final s = AsyncState<int>.loading();
      expect(s.isLoading, true);
      expect(s.hasError, false);
      expect(s.hasValue, false);
      expect(s.value, null);
      expect(s.error, null);
      expect(s.stackTrace, null);
      expect(s.isRefreshing, false);
      expect(s.isReloading, false);
    });

    group('map', () {
      test('data', () {
        final s = AsyncState<int>.data(0);
        int value = -1;
        s.map(
          data: (data) => value = data,
          error: (error, stackTrace) {},
          loading: () {},
        );
        expect(value, 0);
      });

      test('error', () {
        final s = AsyncState<int>.error('error');
        final value = s.map<String>(
          data: (data) => '$data',
          error: (error) => '$error',
          loading: () => '',
        );
        final value2 = s.map<String>(
          data: (data) => '$data',
          error: (error, _) => '$error',
          loading: () => '',
        );
        final value3 = s.map<String>(
          data: (data) => '$data',
          error: () => 'err',
          loading: () => '',
        );
        expect(value, 'error');
        expect(value2, 'error');
        expect(value3, 'err');
      });

      test('loading', () {
        final s = AsyncState<int>.loading();
        bool value = false;
        s.map(
          data: (data) {},
          error: (error, stackTrace) {},
          loading: () => value = true,
        );
        expect(value, true);
      });
    });

    group('maybeMap', () {
      test('data', () {
        final s = AsyncState<int>.data(0);
        int value = -1;
        s.maybeMap(
          data: (data) => value = data,
          orElse: () {},
        );
        expect(value, 0);
      });

      test('orElse', () {
        final s = AsyncState<int>.data(0);
        int value = -1;
        s.maybeMap(
          error: (error, stackTrace) {},
          orElse: () => value = 1,
        );
        expect(value, 1);
      });

      test('hashCode', () {
        final s = AsyncState<int>.data(0);
        final value = s.hashCode;
        expect(value != 0, true);
      });

      test('equality', () {
        final s = AsyncState<int>.data(0);
        final value = s == AsyncState<int>.data(0);
        expect(value, true);
      });

      test('error', () {
        final s = AsyncState<int>.error('error');
        final value = s.maybeMap<String>(
          data: (data) => '$data',
          error: (error) => '$error',
          orElse: () => '',
        );
        final value2 = s.maybeMap<String>(
          data: (data) => '$data',
          error: (error, _) => '$error',
          orElse: () => '',
        );
        final value3 = s.maybeMap<String>(
          data: (data) => '$data',
          error: () => 'err',
          orElse: () => '',
        );
        expect(value, 'error');
        expect(value2, 'error');
        expect(value3, 'err');
      });

      test('loading', () {
        final s = AsyncState<int>.loading();
        bool value = false;
        s.maybeMap(
          loading: () => value = true,
          orElse: () {},
        );
        expect(value, true);
      });
    });

    group('pattern matching', () {
      test('loading', () {
        final s = AsyncState<int>.loading();
        int value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 3);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 7);
      });

      test('data', () {
        var s = AsyncState<int>.data(0);
        int value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 1);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 3);
        s = AsyncState<int>.dataRefreshing(0);
        value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 1);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 1);
        s = AsyncState<int>.dataReloading(0);
        value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 1);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
      });

      test('error', () {
        var s = AsyncState<int>.error('error');
        int value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 2);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 6);
        s = AsyncState<int>.errorRefreshing('error');
        value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 2);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 4);
        s = AsyncState<int>.errorReloading('error');
        value = switch (s) {
          AsyncData<int>() => 1,
          AsyncError<int>() => 2,
          AsyncLoading<int>() => 3,
        };
        expect(value, 2);
        value = switch (s) {
          AsyncDataRefreshing<int>() => 1,
          AsyncDataReloading<int>() => 2,
          AsyncData<int>() => 3,
          AsyncErrorRefreshing() => 4,
          AsyncErrorReloading() => 5,
          AsyncError<int>() => 6,
          AsyncLoading<int>() => 7,
        };
        expect(value, 5);
      });
    });
  });
}
