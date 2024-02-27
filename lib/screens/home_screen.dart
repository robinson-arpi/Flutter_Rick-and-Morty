import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rickandmortyapp/providers/api_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  bool isLoading = false;
  int page = 1;
  @override
  void initState() {
    super.initState();
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    apiProvider.getCharacteres(page);
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading;
          true;
        });
        page++;
        await apiProvider.getCharacteres(page);
        setState(() {
          isLoading;
          false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Rick and Morty",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: apiProvider.characteres.isNotEmpty
              ? CharacterList(
                  apiProvider: apiProvider,
                  scrollController: scrollController,
                  isLoading: isLoading,
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}

class CharacterList extends StatelessWidget {
  const CharacterList(
      {super.key,
      required this.apiProvider,
      required this.scrollController,
      required this.isLoading});
  final ApiProvider apiProvider;
  final ScrollController scrollController;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.87,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: isLoading
            ? apiProvider.characteres.length + 2
            : apiProvider.characteres.length,
        controller: scrollController,
        itemBuilder: (contect, index) {
          if (index < apiProvider.characteres.length) {
            final character = apiProvider.characteres[index];
            return GestureDetector(
                onTap: () {
                  context.go('/character', extra: character);
                },
                child: Card(
                  child: Column(
                    children: [
                      Hero(
                        tag: character.id!,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/portal.gif'),
                          image: NetworkImage(character.image!),
                        ),
                      ),
                      Text(
                        character.name!,
                        style: TextStyle(
                            fontSize: 16, overflow: TextOverflow.ellipsis),
                      )
                    ],
                  ),
                ));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
