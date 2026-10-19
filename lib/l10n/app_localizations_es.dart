// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'Japonés',
      'zhHant': 'Chino (tradicional)',
      'es': 'Español',
      'fr': 'Francés',
      'enDefinition': 'Inglés (definiciones)',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'japonés',
      'zhHant': 'chino',
      'es': 'español',
      'fr': 'francés',
      'enDefinition': 'definición',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => 'Aprendiendo';

  @override
  String get navLearningWords => 'Palabras en estudio';

  @override
  String get navAllWords => 'Todas las palabras';

  @override
  String get navQuiz => 'Quiz rápido';

  @override
  String get navQuizShort => 'Quiz';

  @override
  String get navRegistration => 'Añadir palabra';

  @override
  String get navSettings => 'Ajustes';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '1 palabra',
    );
    return '$_temp0';
  }

  @override
  String showingWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '1 palabra',
    );
    return 'Mostrando $_temp0';
  }

  @override
  String get addShort => '＋ Añadir';

  @override
  String get addWord => '＋ Añadir palabra';

  @override
  String get search => 'Buscar';

  @override
  String get menuWords => 'Palabras';

  @override
  String get menuEdit => 'Edición';

  @override
  String get menuWindow => 'Ventana';

  @override
  String get sidebarTitle => 'Vocabulario';

  @override
  String get sidebarSavedLocally => 'Guardado en este Mac';

  @override
  String get posNoun => 'sustantivo';

  @override
  String get posVerb => 'verbo';

  @override
  String get posAdjective => 'adjetivo';

  @override
  String get posAdverb => 'adverbio';

  @override
  String get posOther => 'otro';

  @override
  String get posSeparator => '/';

  @override
  String get fieldWord => 'Palabra en inglés *';

  @override
  String get fieldIpa => 'Pronunciación (AFI)';

  @override
  String fieldMeaning(String language) {
    return 'Traducción ($language) *';
  }

  @override
  String get fieldDefinition => 'Definición *';

  @override
  String get fieldPartsOfSpeech =>
      'Categoría gramatical (elige las que quieras)';

  @override
  String get fieldExampleEn => 'Ejemplo (inglés)';

  @override
  String fieldExampleTranslation(String language) {
    return 'Ejemplo ($language)';
  }

  @override
  String get manualInputHint => 'Escribe manualmente';

  @override
  String registrationIntro(String language) {
    return 'Escribe una palabra en inglés y se completarán desde el diccionario su pronunciación, su traducción al $language, ejemplos y más.';
  }

  @override
  String get registrationIntroDefinition =>
      'Escribe una palabra en inglés y se completarán desde el diccionario su pronunciación, su definición, ejemplos y más.';

  @override
  String get autoFill => 'Autocompletar';

  @override
  String get autoFillBadge => 'Autocompletado';

  @override
  String get skipToManual => 'Omitir y escribir manualmente';

  @override
  String get fetchingDictionary => 'Buscando en el diccionario...';

  @override
  String exampleTranslationFailed(String language) {
    return 'No se pudo obtener la traducción del ejemplo al $language. Puedes escribirla manualmente.';
  }

  @override
  String get exampleTranslationFailedShort =>
      'No se pudo traducir el ejemplo (puedes escribirlo manualmente)';

  @override
  String get registerButton => 'Añadir';

  @override
  String get registerShort => 'Añadir';

  @override
  String get back => 'Atrás';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get noticeNotFound =>
      'No se encontró en el diccionario. Puedes escribirla manualmente.';

  @override
  String noticeMeaningNotFound(String language) {
    return 'No se encontró la traducción al $language en el diccionario (escríbela manualmente)';
  }

  @override
  String get noticeOnlyMeaningFound =>
      'No se encontró la pronunciación ni ejemplos (solo se completó la traducción)';

  @override
  String errorDuplicate(String word) {
    return '\"$word\" ya está en tu lista de palabras.';
  }

  @override
  String get errorEmptyWord => 'Escribe una palabra en inglés.';

  @override
  String get errorFetchFailed =>
      'No se pudo conectar con el diccionario. Revisa tu conexión.';

  @override
  String errorRequiredFields(String language) {
    return 'La palabra en inglés y la traducción son obligatorias.';
  }

  @override
  String get editWordTitle => 'Editar palabra';

  @override
  String get deleteThisWord => 'Eliminar esta palabra';

  @override
  String get editEllipsis => 'Editar...';

  @override
  String get deleteEllipsis => 'Eliminar...';

  @override
  String deleteConfirmTitle(String word) {
    return '¿Eliminar \"$word\"?';
  }

  @override
  String get deleteConfirmBody => 'Esta acción no se puede deshacer.';

  @override
  String get deleteConfirmCancel => 'Cancelar';

  @override
  String get deleteConfirmOk => 'Eliminar';

  @override
  String get noExample => 'Sin ejemplo';

  @override
  String get markLearned => 'Marcar como aprendida';

  @override
  String showMeaningWithLanguage(String language) {
    return 'Mostrar traducción';
  }

  @override
  String get showMeaning => 'Mostrar traducción';

  @override
  String get showDefinition => 'Mostrar definición';

  @override
  String correctCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recordada $count veces',
      one: 'Recordada 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get rememberedCheck => 'Aprendida';

  @override
  String get learningHint =>
      'Marca una palabra como aprendida para quitarla de esta lista. Haz clic en una tarjeta para editarla (clic derecho para más opciones).';

  @override
  String get noWordsYet => 'Aún no hay palabras.';

  @override
  String get learningEmpty =>
      'No hay palabras en estudio.\nAñade algunas palabras para empezar.';

  @override
  String sortOrderLabel(String order) {
    return 'Orden: $order';
  }

  @override
  String get sortSheetTitle => 'Ordenar';

  @override
  String get sortNewest => 'Más recientes primero';

  @override
  String get sortOldest => 'Más antiguas primero';

  @override
  String get sortLearningFirst => 'En estudio → Aprendidas';

  @override
  String get sortLearnedFirst => 'Aprendidas → En estudio';

  @override
  String get sortMostCorrect => 'Más recordadas';

  @override
  String get sortLeastCorrect => 'Menos recordadas';

  @override
  String get tableLearned => 'Aprendida';

  @override
  String get tableWord => 'Palabra';

  @override
  String get tableIpa => 'AFI';

  @override
  String get tablePartOfSpeech => 'Categoría';

  @override
  String tableMeaning(String language) {
    return 'Traducción';
  }

  @override
  String get tableDefinition => 'Definición';

  @override
  String get tableExample => 'Ejemplo';

  @override
  String get tablePronunciation => 'Audio';

  @override
  String get showAnswer => 'Ver respuesta';

  @override
  String get quizForgot => 'La olvidé';

  @override
  String get quizRemembered => 'La recordé';

  @override
  String get quizForgotHint =>
      'Si eliges \"La olvidé\", la palabra vuelve a tu lista de estudio';

  @override
  String get quizEmpty =>
      'Aún no hay palabras para repasar.\nAquí aparecerán las palabras que marques como aprendidas.';

  @override
  String get toLearningList => 'Ir a la lista de estudio';

  @override
  String get quizDone => 'Repaso terminado';

  @override
  String quizSummary(int ok, int forgot) {
    return 'Recordadas $ok / Olvidadas $forgot';
  }

  @override
  String get quizContinue => 'Continuar';

  @override
  String get quizForgotWordsHeader =>
      'Palabras olvidadas (volvieron a tu lista de estudio)';

  @override
  String quizDirectionFromEnglish(String language) {
    return 'Del inglés al $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return 'Del $language al inglés';
  }

  @override
  String get sectionDisplay => 'Pantalla';

  @override
  String get theme => 'Tema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get cardLayout => 'Diseño de las tarjetas';

  @override
  String get layoutTwoColumns => '2 columnas (compacto)';

  @override
  String get layoutOneColumn => '1 columna (ancho completo)';

  @override
  String get showIpa => 'Mostrar pronunciación (AFI)';

  @override
  String get sectionQuiz => 'Quiz';

  @override
  String get sectionTranslation => 'Idioma de traducción';

  @override
  String get translationLanguageCaption =>
      'Las palabras nuevas se traducen a este idioma. Las palabras que ya añadiste conservan su traducción.';

  @override
  String get sectionData => 'Datos';

  @override
  String get sectionSupport => 'Ayuda';

  @override
  String get writeReview => 'Escribir una reseña en la App Store';

  @override
  String get sectionAuthorApps => 'Más apps del desarrollador';

  @override
  String get getApp => 'Obtener';

  @override
  String get sectionInfo => 'Información';

  @override
  String get version => 'Versión';

  @override
  String get licenses => 'Licencias';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licencias',
      one: 'Licencia',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed =>
      'No se pudo cargar la información de licencias.';

  @override
  String get licenseAutoGenerated =>
      'Esta lista se genera automáticamente al compilar la app.';

  @override
  String get uiScale => 'Tamaño de la pantalla';

  @override
  String get exportDone => 'Exportado';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportDataEllipsis => 'Exportar datos...';

  @override
  String get importData => 'Importar datos';

  @override
  String get importDataEllipsis => 'Importar datos...';

  @override
  String get importDoneTitle => 'Importación terminada';

  @override
  String importAdded(int count) {
    return 'Añadidas: $count';
  }

  @override
  String importUpdated(int count) {
    return 'Actualizadas: $count';
  }

  @override
  String importUnchanged(int count) {
    return 'Sin cambios: $count';
  }

  @override
  String importSkipped(int count) {
    return 'Omitidas: $count';
  }

  @override
  String get importFailedTitle => 'No se pudo importar';

  @override
  String get importErrorInvalidJson => 'No se pudo leer el archivo como JSON.';

  @override
  String get importErrorInvalidFormat => 'El formato del JSON no es válido.';

  @override
  String get importErrorUnsupportedVersion =>
      'Esta versión del archivo no es compatible.';

  @override
  String get deeplKeyHint => 'Escribe tu clave de la API de DeepL';

  @override
  String deeplDescription(String language) {
    return 'Con una clave de DeepL API Free, el autocompletado también traduce el ejemplo en inglés al $language. Sin clave, se omite la traducción del ejemplo.';
  }

  @override
  String get icloudSync => 'Sincronización con iCloud';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get neverSynced => 'Aún no se ha sincronizado';

  @override
  String lastSynced(String time) {
    return 'Última sincronización: $time';
  }

  @override
  String get syncErrorNoICloud =>
      'iCloud no está disponible. Inicia sesión en iCloud Drive desde Ajustes.';

  @override
  String get syncErrorNotCurrent =>
      'Se omitió la sincronización porque no se pudieron descargar los datos más recientes de iCloud.';

  @override
  String get syncErrorUnsupported =>
      'La sincronización con iCloud no está disponible en esta plataforma.';

  @override
  String syncErrorFailed(String detail) {
    return 'Error al sincronizar: $detail';
  }

  @override
  String get proCoffeeTitle => 'Invítale un café al desarrollador ☕';

  @override
  String get proCoffeeReward => 'Como agradecimiento, quitamos los anuncios';

  @override
  String get proCoffeeThanks => '¡Gracias por el café!';

  @override
  String get proCoffeeLink => 'Invítame un café y adiós anuncios ☕';

  @override
  String get priceUnavailable => 'No se pudo obtener el precio';

  @override
  String oneTimePrice(String price) {
    return 'Pago único $price';
  }

  @override
  String get purchased => 'Comprado';

  @override
  String get purchase => 'Comprar';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchaseFailed => 'No se pudo completar la compra';

  @override
  String get restoreChecking => 'Comprobando…';

  @override
  String get restoreDone => 'Restaurado';

  @override
  String get restoreNotFound => 'No se encontraron compras anteriores';

  @override
  String get restoreFailed => 'No se pudo restaurar';

  @override
  String get listenPronunciation => 'Escuchar';

  @override
  String get pronunciationShort => 'Audio';

  @override
  String get pronunciationTooltip =>
      'Comprobar la pronunciación en Google Traductor';

  @override
  String get pageLoadFailed =>
      'No se pudo cargar la página.\nRevisa tu conexión e inténtalo de nuevo.';

  @override
  String get reload => 'Volver a cargar';
}
