import 'package:askaide/bloc/bloc_manager.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/creative_island_repo.dart';
import 'package:flutter/material.dart';

part 'creative_island_event.dart';
part 'creative_island_state.dart';

class CreativeIslandBloc
    extends BlocExt<CreativeIslandEvent, CreativeIslandState> {
  final CreativeIslandRepository creativeIslandRepo;

  CreativeIslandBloc(this.creativeIslandRepo) : super(CreativeIslandInitial()) {
    // on<CreativeIslandSaveEvent>((event, emit) async {
    //   await creativeIslandRepo.create(
    //     event.itemId,
    //     arguments: jsonEncode(event.arguments),
    //     prompt: event.prompt,
    //     answer: event.answer,
    //     userId: APIServer().localUserID(),
    //   );
    //   emit(CreativeIslandSaved());
    // });

    on<CreativeIslandItemsV2LoadEvent>((event, emit) async {
      final items =
          await APIServer().creativeIslandItemsV2(cache: !event.forceRefresh);
      emit(CreativeIslandItemsV2Loaded(
        items: items,
      ));
    });

    on<CreativeIslandItemLoadEvent>((event, emit) async {
      final resp = await APIServer().creativeIslandItem(event.itemId);
      emit(CreativeIslandItemLoaded(resp));
    });

    on<CreativeIslandHistoriesAllLoadEvent>((event, emit) async {
      emit(CreativeIslandHistoriesLoading());

      final items = await APIServer()
          .creativeHistories(cache: !event.forceRefresh, mode: event.mode);
      emit(CreativeIslandHistoriesAllLoaded(items.data));
    });

    on<CreativeIslandGalleryLoadEvent>((event, emit) async {
      emit(CreativeIslandHistoriesLoading());

      final items = await APIServer().creativeUserGallery(
          cache: false, mode: event.mode, model: event.model);
      emit(CreativeIslandGalleryLoaded(items));
    });

    on<CreativeIslandHistoriesLoadEvent>((event, emit) async {
      emit(CreativeIslandHistoriesLoading());
      final island = await APIServer().creativeIslandItem(event.itemId);

      emit(CreativeIslandHistoriesLoaded(
        island,
        await APIServer().creativeItemHistories(
          island.id,
          cache: !event.forceRefresh,
        ),
      ));
    });

    on<CreativeIslandDeleteEvent>((event, emit) async {
      emit(CreativeIslandHistoriesLoading());
      await APIServer()
          .deleteCreativeHistoryItem(event.itemId, hisId: event.id);

      if (event.source == 'all-histories') {
        final res =
            await APIServer().creativeHistories(cache: false, mode: event.mode);
        emit(CreativeIslandHistoriesAllLoaded(res.data));
      } else {
        final island = await APIServer().creativeIslandItem(event.itemId);
        emit(CreativeIslandHistoriesLoaded(
          island,
          await APIServer().creativeItemHistories(
            island.id,
            cache: false,
          ),
        ));
      }
    });

    on<CreativeIslandListLoadEvent>((event, emit) async {
      emit(CreativeIslandInitial());

      try {
        final items = await APIServer().creativeIslandItems(mode: event.mode);

        emit(CreativeIslandListLoaded(
          items.items,
          categories: items.categories,
          backgroundImage: items.backgroundImage,
        ));
      } catch (e) {
        emit(
            CreativeIslandListLoaded(const [], error: e, categories: const []));
      }
    });

    on<CreativeIslandHistoryItemLoadEvent>((event, emit) async {
      emit(CreativeIslandHistoryItemLoaded(
        item: await APIServer().creativeHistoryItem(
          hisId: event.itemId,
          cache: !event.forceRefresh,
        ),
      ));
    });
  }
}
