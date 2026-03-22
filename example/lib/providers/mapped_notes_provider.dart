import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_craft/riverpod_craft.dart';
import '../models/note.dart';
import '../models/api_paged_response.dart';
import '../paged_mapper.dart';

part 'mapped_notes_provider.pg.dart';

/// Example: paged provider with global mapper.
///
/// Use `Paged<Note>` as the return type — this tells the generator:
///   1. It's a paged provider (data type = Note)
///   2. First `int page` param is the page key
///
/// With `paged_provider_mapper` in riverpod_craft.yaml, the generated
/// abstract class declares `create()` as `Future<dynamic>`. You override
/// it with your raw API type. The generated code wraps it:
///
///   buildPagedData(int page) async =>
///       pagedMapper(await create(page, category: arg.category));
@provider
class MappedNotes extends _$MappedNotes {
  /// Override returns the raw API model.
  /// The generated code passes the result to pagedMapper() automatically.
  @override
  Paged<Note> create(int page, {required String? category}) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes?page=$page&category=$category'),
    );
    return ApiPagedResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      (json) => '' as Note,
    );
  }
}

@provider
class XMappedNotes extends _$XMappedNotes {
  /// Override returns the raw API model.
  /// The generated code passes the result to pagedMapper() automatically.
  @override
  Paged<Note> create(int page, {required String? category}) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes?page=$page&category=$category'),
    );
    return '' as Paged<Note>;
  }
}

void x(Ref ref) {
  ref.xMappedNotesProvider(category: '');

  ref.mappedNotesProvider(category: '');
}
