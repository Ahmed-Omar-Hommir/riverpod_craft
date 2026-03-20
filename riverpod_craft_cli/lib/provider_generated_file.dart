import 'dart:io';

import 'provider_data_collection.dart';

class ProviderGeneratedFile {
  const ProviderGeneratedFile({
    required this.file,
    required this.providerDataCollection,
  });
  final ProviderDataCollection providerDataCollection;
  final File file;

  String? build() => providerDataCollection.build();
}
