import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:venera/components/components.dart';
import 'package:venera/foundation/app.dart';
import 'package:venera/foundation/favorites.dart';
import 'package:venera/foundation/history.dart';
import 'package:venera/foundation/local.dart';
import 'package:venera/foundation/log.dart';
import 'package:venera/pages/comic_details_page/comic_page.dart';
import 'package:venera/pages/downloading_page.dart';
import 'package:venera/pages/favorites/favorites_page.dart';
import 'package:venera/pages/follow_updates_page.dart';
import 'package:venera/pages/image_favorites_page/image_favorites_page.dart';
import 'package:venera/pages/local_comics_page.dart';
import 'package:venera/utils/import_comic.dart';
import 'package:venera/utils/tags_translation.dart';
import 'package:venera/utils/translations.dart';

class FavoritesHubPage extends StatelessWidget {
  const FavoritesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmoothCustomScrollView(
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: context.padding.top)),
        const _FavoritesSection(),
        const LocalSection(),
        const FollowUpdatesWidget(),
        const ImageFavorites(),
        SliverPadding(padding: EdgeInsets.only(top: context.padding.bottom)),
      ],
    );
  }
}

class _FavoritesSection extends StatefulWidget {
  const _FavoritesSection();

  @override
  State<_FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<_FavoritesSection> {
  late int count;

  void onFavoritesChange() {
    if (mounted) {
      setState(() {
        count = LocalFavoritesManager().totalComics;
      });
    }
  }

  @override
  void initState() {
    count = LocalFavoritesManager().totalComics;
    LocalFavoritesManager().addListener(onFavoritesChange);
    super.initState();
  }

  @override
  void dispose() {
    LocalFavoritesManager().removeListener(onFavoritesChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context.to(
              () => Scaffold(
                appBar: AppBar(
                  leading: const BackButton(),
                  title: Text('Favorites'.tl),
                ),
                body: const FavoritesPage(),
              ),
            );
          },
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Center(
                  child: Text('Favorites'.tl, style: ts.s18),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(count.toString(), style: ts.s12),
                ),
                const Spacer(),
                const Icon(Icons.arrow_right),
              ],
            ),
          ).paddingHorizontal(16),
        ),
      ),
    );
  }
}

class LocalSection extends StatefulWidget {
  const LocalSection({super.key});

  @override
  State<LocalSection> createState() => _LocalSectionState();
}

class _LocalSectionState extends State<LocalSection> {
  late int count;
  late List<LocalComic> recent;
  bool expanded = false;

  void onLocalComicsChange() {
    if (mounted) {
      setState(() {
        count = LocalManager().count;
        recent = LocalManager().getRecent();
      });
    }
  }

  @override
  void initState() {
    count = LocalManager().count;
    recent = LocalManager().getRecent();
    LocalManager().addListener(onLocalComicsChange);
    super.initState();
  }

  @override
  void dispose() {
    LocalManager().removeListener(onLocalComicsChange);
    super.dispose();
  }

  void import() {
    showDialog(
      barrierDismissible: false,
      context: App.rootContext,
      builder: (context) {
        return const _ImportComicsWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Center(
                      child: Text('Local'.tl, style: ts.s18),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(count.toString(), style: ts.s12),
                    ),
                    const Spacer(),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ).paddingHorizontal(16),
              if (expanded && recent.isNotEmpty)
                SizedBox(
                  height: 136,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length > 10 ? 10 : recent.length,
                    itemBuilder: (context, index) {
                      final heroID = recent[index].id.hashCode;
                      return SimpleComicTile(
                        comic: recent[index],
                        heroID: heroID,
                        onTap: () {
                          context.to(
                            () => ComicPage(
                              id: recent[index].id,
                              sourceKey: recent[index].sourceKey,
                              cover: recent[index].cover,
                              title: recent[index].title,
                              heroID: heroID,
                            ),
                          );
                        },
                      ).paddingHorizontal(8).paddingVertical(2);
                    },
                  ),
                ).paddingHorizontal(8).paddingBottom(8),
              if (expanded)
                Row(
                  children: [
                    if (LocalManager().downloadingTasks.isNotEmpty)
                      Button.outlined(
                        child: Row(
                          children: [
                            if (LocalManager()
                                .downloadingTasks
                                .first
                                .isPaused)
                              const Icon(Icons.pause_circle_outline,
                                  size: 18)
                            else
                              const Icon(Icons.download, size: 18),
                            const SizedBox(width: 8),
                            Text("@a Tasks".tlParams({
                              'a': LocalManager()
                                  .downloadingTasks
                                  .length,
                            })),
                          ],
                        ),
                        onPressed: () {
                          showPopUpWidget(context, const DownloadingPage());
                        },
                      ),
                    const Spacer(),
                    Button.outlined(
                      child: Text('Open'.tl),
                      onPressed: () {
                        context.to(() => const LocalComicsPage());
                      },
                    ),
                    const SizedBox(width: 8),
                    Button.filled(
                      onPressed: import,
                      child: Text("Import".tl),
                    ),
                  ],
                ).paddingHorizontal(16).paddingVertical(8),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageFavorites extends StatefulWidget {
  const ImageFavorites({super.key});

  @override
  State<ImageFavorites> createState() => _ImageFavoritesState();
}

class _ImageFavoritesState extends State<ImageFavorites> {
  ImageFavoritesComputed? imageFavoritesCompute;

  int displayType = 0;

  void refreshImageFavorites() async {
    try {
      imageFavoritesCompute =
          await ImageFavoriteManager.computeImageFavorites();
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      Log.error("Unhandled Exception", e.toString(), stackTrace);
    }
  }

  @override
  void initState() {
    refreshImageFavorites();
    ImageFavoriteManager().addListener(refreshImageFavorites);
    super.initState();
  }

  @override
  void dispose() {
    ImageFavoriteManager().removeListener(refreshImageFavorites);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasData =
        imageFavoritesCompute != null && !imageFavoritesCompute!.isEmpty;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context.to(
              () => const ImageFavoritesPage(),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Center(
                      child: Text('Image Favorites'.tl, style: ts.s18),
                    ),
                    if (hasData)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          imageFavoritesCompute!.count.toString(),
                          style: ts.s12,
                        ),
                      ),
                    const Spacer(),
                    const Icon(Icons.arrow_right),
                  ],
                ),
              ).paddingHorizontal(16),
              if (hasData)
                Row(
                  children: [
                    const Spacer(),
                    buildTypeButton(0, "Tags".tl),
                    const Spacer(),
                    buildTypeButton(1, "Authors".tl),
                    const Spacer(),
                    buildTypeButton(2, "Comics".tl),
                    const Spacer(),
                  ],
                ),
              if (hasData) const SizedBox(height: 8),
              if (hasData)
                buildChart(switch (displayType) {
                  0 => imageFavoritesCompute!.tags,
                  1 => imageFavoritesCompute!.authors,
                  2 => imageFavoritesCompute!.comics,
                  _ => [],
                })
                    .paddingHorizontal(16)
                    .paddingBottom(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTypeButton(int type, String text) {
    const radius = 24.0;
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () async {
        setState(() {
          displayType = type;
        });
        await Future.delayed(const Duration(milliseconds: 20));
        var scrollController = ScrollState.of(context).controller;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      },
      child: AnimatedContainer(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color:
              displayType == type ? context.colorScheme.primaryContainer : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: Text(
            text,
            style: ts.s16,
          ),
        ),
      ),
    );
  }

  Widget buildChart(List<TextWithCount> data) {
    if (data.isEmpty) {
      return const SizedBox();
    }
    var maxCount = data.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 164,
      ),
      child: SingleChildScrollView(
        child: Column(
          key: ValueKey(displayType),
          children: data.map((e) {
            return _ChartLine(
              text: e.text,
              count: e.count,
              maxCount: maxCount,
              enableTranslation: displayType != 2,
              onTap: (text) {
                context.to(
                  () => ImageFavoritesPage(initialKeyword: text),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChartLine extends StatefulWidget {
  const _ChartLine({
    required this.text,
    required this.count,
    required this.maxCount,
    required this.enableTranslation,
    this.onTap,
  });

  final String text;

  final int count;

  final int maxCount;

  final bool enableTranslation;

  final void Function(String text)? onTap;

  @override
  State<_ChartLine> createState() => __ChartLineState();
}

class __ChartLineState extends State<_ChartLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 0,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var text = widget.text;
    var enableTranslation =
        App.locale.countryCode == 'CN' && widget.enableTranslation;
    if (enableTranslation) {
      text = text.translateTagsToCN;
    }
    if (widget.enableTranslation && text.contains(':')) {
      text = text.split(':').last;
    }
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            widget.onTap?.call(widget.text);
          },
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
              .paddingHorizontal(4)
              .toAlign(Alignment.centerLeft)
              .fixWidth(context.width > 600 ? 120 : 80)
              .fixHeight(double.infinity),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(builder: (context, constrains) {
            var width = constrains.maxWidth * widget.count / widget.maxCount;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: width * _controller.value,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: context.isDarkMode
                          ? [
                              Colors.blue.shade800,
                              Colors.blue.shade500,
                            ]
                          : [
                              Colors.blue.shade300,
                              Colors.blue.shade600,
                            ],
                    ),
                  ),
                ).toAlign(Alignment.centerLeft);
              },
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          widget.count.toString(),
          style: ts.s12,
        ).fixWidth(context.width > 600 ? 60 : 30),
      ],
    ).fixHeight(28);
  }
}

class _ImportComicsWidget extends StatefulWidget {
  const _ImportComicsWidget();

  @override
  State<_ImportComicsWidget> createState() => _ImportComicsWidgetState();
}

class _ImportComicsWidgetState extends State<_ImportComicsWidget> {
  int type = 0;

  bool loading = false;

  var key = GlobalKey();

  var height = 200.0;

  var folders = LocalFavoritesManager().folderNames;

  String? selectedFolder;

  bool copyToLocalFolder = true;

  bool cancelled = false;

  @override
  void dispose() {
    loading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String info = [
      "Select a directory which contains the comic files.".tl,
      "Select a directory which contains the comic directories.".tl,
      "Select an archive file (cbz, zip, 7z, cb7)".tl,
      "Select a directory which contains multiple archive files.".tl,
      "Select an EhViewer database and a download folder.".tl,
      "Scan the current local path and restore the local database.".tl,
    ][type];
    List<String> importMethods = [
      "Single Comic".tl,
      "Multiple Comics".tl,
      "An archive file".tl,
      "Multiple archive files".tl,
      "EhViewer downloads".tl,
      "Restore local downloads".tl,
    ];

    return ContentDialog(
      dismissible: !loading,
      title: "Import Comics".tl,
      content: loading
          ? SizedBox(
              width: 600,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : RadioGroup<int>(
              groupValue: type,
              onChanged: (value) {
                setState(() {
                  type = value ?? type;
                  if (type == 5) {
                    selectedFolder = null;
                  }
                });
              },
              child: Column(
                key: key,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 600),
                  ...List.generate(importMethods.length, (index) {
                    return RadioListTile<int>(
                      title: Text(importMethods[index]),
                      value: index,
                    );
                  }),
                  if (type != 4 && type != 5)
                    ListTile(
                      title: Text("Add to favorites".tl),
                      trailing: Select(
                        current: selectedFolder,
                        values: folders,
                        minWidth: 112,
                        onTap: (v) {
                          setState(() {
                            selectedFolder = folders[v];
                          });
                        },
                      ),
                    ).paddingHorizontal(8),
                  if (!App.isIOS &&
                      !App.isMacOS &&
                      type != 2 &&
                      type != 3 &&
                      type != 5)
                    CheckboxListTile(
                        enabled: true,
                        title: Text("Copy to app local path".tl),
                        value: copyToLocalFolder,
                        onChanged: (v) {
                          setState(() {
                            copyToLocalFolder = !copyToLocalFolder;
                          });
                        }).paddingHorizontal(8),
                  const SizedBox(height: 8),
                  Text(info).paddingHorizontal(24),
                ],
              ),
          ),
      actions: [
        Button.text(
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 18,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text("help".tl),
            ],
          ),
          onPressed: () {
            launchUrlString(
                "https://github.com/venera-app/venera/blob/master/doc/import_comic.md");
          },
        ).fixWidth(90).paddingRight(8),
        Button.filled(
          isLoading: loading,
          onPressed: selectAndImport,
          child: Text("Select".tl),
        )
      ],
    );
  }

  void selectAndImport() async {
    height = key.currentContext!.size!.height;

    setState(() {
      loading = true;
    });
    var importer = ImportComic(
        selectedFolder: selectedFolder, copyToLocal: copyToLocalFolder);
    var result = switch (type) {
      0 => await importer.directory(true),
      1 => await importer.directory(false),
      2 => await importer.cbz(),
      3 => await importer.multipleCbz(),
      4 => await importer.ehViewer(),
      5 => await importer.localDownloads(),
      int() => true,
    };
    if (result) {
      context.pop();
    } else {
      setState(() {
        loading = false;
      });
    }
  }
}

