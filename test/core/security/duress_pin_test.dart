import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intima/core/security/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Duress PIN (Mode sous-contrainte) Tests', () {
    test('Par défaut, aucun code leurre n\'est configuré', () async {
      final hasDuress = await SecurityService.hasDuressPinConfigured();
      expect(hasDuress, isFalse);
    });

    test('Configuration et vérification du code PIN principal et du code leurre', () async {
      const realPin = '123456';
      const duressPin = '654321';

      // Configurer le PIN réel
      await SecurityService.setPin(realPin);
      expect(await SecurityService.hasPinConfigured(), isTrue);

      // Configurer le PIN leurre
      await SecurityService.setDuressPin(duressPin);
      expect(await SecurityService.hasDuressPinConfigured(), isTrue);

      // Vérification du PIN réel
      final realResult = await SecurityService.verifyPinDetailed(realPin);
      expect(realResult, equals(PinVerificationResult.success));

      // Vérification du PIN leurre
      final duressResult = await SecurityService.verifyPinDetailed(duressPin);
      expect(duressResult, equals(PinVerificationResult.duress));

      // Vérification d'un mauvais code PIN
      final invalidResult = await SecurityService.verifyPinDetailed('999999');
      expect(invalidResult, equals(PinVerificationResult.incorrect));
    });

    test('Suppression du code PIN leurre', () async {
      const realPin = '123456';
      const duressPin = '654321';
      await SecurityService.setPin(realPin);

      await SecurityService.setDuressPin(duressPin);
      expect(await SecurityService.hasDuressPinConfigured(), isTrue);

      await SecurityService.deleteDuressPin();
      expect(await SecurityService.hasDuressPinConfigured(), isFalse);

      final resultAfterDelete = await SecurityService.verifyPinDetailed(duressPin);
      expect(resultAfterDelete, equals(PinVerificationResult.incorrect));
    });
  });
}
