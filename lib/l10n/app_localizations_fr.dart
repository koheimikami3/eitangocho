// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'Japonais',
      'zhHant': 'Chinois (traditionnel)',
      'es': 'Espagnol',
      'fr': 'Français',
      'enDefinition': 'Anglais (définitions)',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'japonais',
      'zhHant': 'chinois',
      'es': 'espagnol',
      'fr': 'français',
      'enDefinition': 'définition',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => 'En cours';

  @override
  String get navLearningWords => 'Mots en cours';

  @override
  String get navAllWords => 'Tous les mots';

  @override
  String get navQuiz => 'Quiz express';

  @override
  String get navQuizShort => 'Quiz';

  @override
  String get navRegistration => 'Ajouter un mot';

  @override
  String get navSettings => 'Réglages';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots',
      one: '$count mot',
    );
    return '$_temp0';
  }

  @override
  String showingWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots affichés',
      one: '$count mot affiché',
    );
    return '$_temp0';
  }

  @override
  String get addShort => '＋ Ajouter';

  @override
  String get addWord => '＋ Ajouter un mot';

  @override
  String get search => 'Rechercher';

  @override
  String get menuWords => 'Mots';

  @override
  String get menuEdit => 'Édition';

  @override
  String get menuWindow => 'Fenêtre';

  @override
  String get sidebarTitle => 'Vocabulaire';

  @override
  String get sidebarSavedLocally => 'Enregistré sur ce Mac';

  @override
  String get posNoun => 'nom';

  @override
  String get posVerb => 'verbe';

  @override
  String get posAdjective => 'adjectif';

  @override
  String get posAdverb => 'adverbe';

  @override
  String get posOther => 'autre';

  @override
  String get posSeparator => '/';

  @override
  String get fieldWord => 'Mot anglais *';

  @override
  String get fieldIpa => 'Prononciation (API)';

  @override
  String fieldMeaning(String language) {
    return 'Traduction ($language) *';
  }

  @override
  String get fieldDefinition => 'Définition *';

  @override
  String get fieldPartsOfSpeech => 'Nature du mot (choix multiple)';

  @override
  String get fieldExampleEn => 'Exemple (anglais)';

  @override
  String fieldExampleTranslation(String language) {
    return 'Exemple ($language)';
  }

  @override
  String get manualInputHint => 'Saisie manuelle';

  @override
  String registrationIntro(String language) {
    return 'Saisissez un mot anglais pour remplir automatiquement sa prononciation, sa traduction en $language, des exemples et plus encore à partir du dictionnaire.';
  }

  @override
  String get registrationIntroDefinition =>
      'Saisissez un mot anglais pour remplir automatiquement sa prononciation, sa définition, des exemples et plus encore à partir du dictionnaire.';

  @override
  String get autoFill => 'Remplir automatiquement';

  @override
  String get autoFillBadge => 'Automatique';

  @override
  String get skipToManual => 'Passer et saisir manuellement';

  @override
  String get fetchingDictionary => 'Recherche dans le dictionnaire...';

  @override
  String exampleTranslationFailed(String language) {
    return 'Impossible d\'obtenir la traduction de l\'exemple en $language. Vous pouvez la saisir manuellement.';
  }

  @override
  String get exampleTranslationFailedShort =>
      'Impossible de traduire l\'exemple (vous pouvez le saisir manuellement)';

  @override
  String get registerButton => 'Ajouter';

  @override
  String get registerShort => 'Ajouter';

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get noticeNotFound =>
      'Introuvable dans le dictionnaire. Vous pouvez le saisir manuellement.';

  @override
  String noticeMeaningNotFound(String language) {
    return 'Aucune traduction en $language trouvée dans le dictionnaire (saisissez-la manuellement)';
  }

  @override
  String get noticeOnlyMeaningFound =>
      'Aucune prononciation ni aucun exemple trouvés (seule la traduction a été remplie)';

  @override
  String errorDuplicate(String word) {
    return '« $word » est déjà dans votre liste de mots.';
  }

  @override
  String get errorEmptyWord => 'Veuillez saisir un mot anglais.';

  @override
  String get errorFetchFailed =>
      'Impossible de joindre le dictionnaire. Vérifiez votre connexion.';

  @override
  String errorRequiredFields(String language) {
    return 'Le mot anglais et la traduction sont obligatoires.';
  }

  @override
  String get editWordTitle => 'Modifier le mot';

  @override
  String get deleteThisWord => 'Supprimer ce mot';

  @override
  String get editEllipsis => 'Modifier...';

  @override
  String get deleteEllipsis => 'Supprimer...';

  @override
  String deleteConfirmTitle(String word) {
    return 'Supprimer « $word » ?';
  }

  @override
  String get deleteConfirmBody => 'Cette action est irréversible.';

  @override
  String get deleteConfirmCancel => 'Annuler';

  @override
  String get deleteConfirmOk => 'Supprimer';

  @override
  String get noExample => 'Aucun exemple';

  @override
  String get markLearned => 'Marquer comme appris';

  @override
  String showMeaningWithLanguage(String language) {
    return 'Afficher la traduction';
  }

  @override
  String get showMeaning => 'Afficher la traduction';

  @override
  String get showDefinition => 'Afficher la définition';

  @override
  String correctCount(int count) {
    return 'Retenu $count fois';
  }

  @override
  String get rememberedCheck => 'Appris';

  @override
  String get learningHint =>
      'Cochez un mot pour le marquer comme appris et le retirer de cette liste. Cliquez sur une carte pour la modifier (clic droit pour plus d\'options).';

  @override
  String get noWordsYet => 'Aucun mot pour l\'instant.';

  @override
  String get learningEmpty =>
      'Aucun mot en cours.\nAjoutez des mots pour commencer.';

  @override
  String sortOrderLabel(String order) {
    return 'Tri : $order';
  }

  @override
  String get sortSheetTitle => 'Trier';

  @override
  String get sortNewest => 'Plus récents d\'abord';

  @override
  String get sortOldest => 'Plus anciens d\'abord';

  @override
  String get sortLearningFirst => 'En cours → Appris';

  @override
  String get sortLearnedFirst => 'Appris → En cours';

  @override
  String get sortMostCorrect => 'Les plus retenus';

  @override
  String get sortLeastCorrect => 'Les moins retenus';

  @override
  String get tableLearned => 'Appris';

  @override
  String get tableWord => 'Mot';

  @override
  String get tableIpa => 'API';

  @override
  String get tablePartOfSpeech => 'Nature';

  @override
  String tableMeaning(String language) {
    return 'Traduction';
  }

  @override
  String get tableDefinition => 'Définition';

  @override
  String get tableExample => 'Exemple';

  @override
  String get tablePronunciation => 'Audio';

  @override
  String get showAnswer => 'Voir la réponse';

  @override
  String get quizForgot => 'Oublié';

  @override
  String get quizRemembered => 'Retenu';

  @override
  String get quizForgotHint =>
      'Choisir « Oublié » remet le mot dans votre liste en cours';

  @override
  String get quizEmpty =>
      'Aucun mot à réviser pour l\'instant.\nLes mots que vous marquez comme appris apparaîtront ici.';

  @override
  String get toLearningList => 'Aller à la liste en cours';

  @override
  String get quizDone => 'Révision terminée';

  @override
  String quizSummary(int ok, int forgot) {
    return 'Retenus $ok / Oubliés $forgot';
  }

  @override
  String get quizContinue => 'Continuer';

  @override
  String get quizForgotWordsHeader =>
      'Mots oubliés (remis dans votre liste en cours)';

  @override
  String quizDirectionFromEnglish(String language) {
    return 'Traduire en $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return 'Traduire en anglais';
  }

  @override
  String get sectionDisplay => 'Affichage';

  @override
  String get theme => 'Thème';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get cardLayout => 'Disposition des cartes';

  @override
  String get layoutTwoColumns => '2 colonnes (compact)';

  @override
  String get layoutOneColumn => '1 colonne (pleine largeur)';

  @override
  String get showIpa => 'Afficher la prononciation (API)';

  @override
  String get sectionQuiz => 'Quiz';

  @override
  String get sectionTranslation => 'Langue de traduction';

  @override
  String get translationLanguageCaption =>
      'Les nouveaux mots sont traduits dans cette langue. Les mots déjà ajoutés gardent leur traduction.';

  @override
  String get sectionData => 'Données';

  @override
  String get sectionSupport => 'Assistance';

  @override
  String get writeReview => 'Laisser un avis sur l\'App Store';

  @override
  String get sectionAuthorApps => 'Autres apps du développeur';

  @override
  String get getApp => 'Obtenir';

  @override
  String get sectionInfo => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get licenses => 'Licences';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licences',
      one: 'Licence',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed =>
      'Impossible de charger les informations de licence.';

  @override
  String get licenseAutoGenerated =>
      'Cette liste est générée automatiquement lors de la compilation.';

  @override
  String get uiScale => 'Taille d\'affichage';

  @override
  String get exportDone => 'Exporté';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportDataEllipsis => 'Exporter les données...';

  @override
  String get importData => 'Importer des données';

  @override
  String get importDataEllipsis => 'Importer des données...';

  @override
  String get importDoneTitle => 'Importation terminée';

  @override
  String importAdded(int count) {
    return 'Ajoutés : $count';
  }

  @override
  String importUpdated(int count) {
    return 'Mis à jour : $count';
  }

  @override
  String importUnchanged(int count) {
    return 'Inchangés : $count';
  }

  @override
  String importSkipped(int count) {
    return 'Ignorés : $count';
  }

  @override
  String get importFailedTitle => 'Impossible d\'importer';

  @override
  String get importErrorInvalidJson =>
      'Le fichier n\'a pas pu être lu en tant que JSON.';

  @override
  String get importErrorInvalidFormat => 'Le format JSON n\'est pas valide.';

  @override
  String get importErrorUnsupportedVersion =>
      'Cette version de fichier n\'est pas prise en charge.';

  @override
  String get deeplKeyHint => 'Saisissez votre clé d\'API DeepL';

  @override
  String deeplDescription(String language) {
    return 'Avec une clé DeepL API Free, le remplissage automatique traduit aussi l\'exemple anglais en $language. Sans clé, la traduction de l\'exemple est ignorée.';
  }

  @override
  String get icloudSync => 'Synchronisation iCloud';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncing => 'Synchronisation...';

  @override
  String get neverSynced => 'Pas encore synchronisé';

  @override
  String lastSynced(String time) {
    return 'Dernière synchronisation : $time';
  }

  @override
  String get syncErrorNoICloud =>
      'iCloud n\'est pas disponible. Connectez-vous à iCloud Drive dans Réglages.';

  @override
  String get syncErrorNotCurrent =>
      'La synchronisation a été ignorée, car les dernières données n\'ont pas pu être téléchargées depuis iCloud.';

  @override
  String get syncErrorUnsupported =>
      'La synchronisation iCloud n\'est pas disponible sur cette plateforme.';

  @override
  String syncErrorFailed(String detail) {
    return 'Échec de la synchronisation : $detail';
  }

  @override
  String get proCoffeeTitle => 'Offrez un café au développeur ☕';

  @override
  String get proCoffeeReward => 'En remerciement, les pubs disparaissent';

  @override
  String get proCoffeeThanks => 'Merci pour le café !';

  @override
  String get proCoffeeLink => 'Offrez-moi un café pour retirer les pubs ☕';

  @override
  String get priceUnavailable => 'Impossible d\'obtenir le prix';

  @override
  String oneTimePrice(String price) {
    return 'Achat unique $price';
  }

  @override
  String get purchased => 'Acheté';

  @override
  String get purchase => 'Acheter';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchaseFailed => 'Impossible de finaliser l\'achat';

  @override
  String get restoreChecking => 'Vérification…';

  @override
  String get restoreDone => 'Restauré';

  @override
  String get restoreNotFound => 'Aucun achat précédent trouvé';

  @override
  String get restoreFailed => 'Impossible de restaurer';

  @override
  String get listenPronunciation => 'Écouter';

  @override
  String get pronunciationShort => 'Audio';

  @override
  String get pronunciationTooltip =>
      'Vérifier la prononciation sur Google Traduction';

  @override
  String get pageLoadFailed =>
      'Impossible de charger la page.\nVérifiez votre connexion et réessayez.';

  @override
  String get reload => 'Recharger';
}
