# Rick & Morty
A sample iOS application using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).
The application uses the [The Rick and Morty API](https://rickandmortyapi.com/documentation) to display list of characters and basic information about them.
The application aims to be modular following Clean Architecture guidelines and implementing repository patterns or separate worker classes for more advanced application logic. The Views are composed using TCA with the minimal business logic provided as part of Reducers. They connect to workers and repositories via TCA's Dependencies which unfortunately have to be provided as bridging structs due to TCA's inner architecture, and I am against writing complex logic in closures :)
## Features
- Infinite scroll pagination and `LazyVStack` for minimising the memory footprint of the application.
- `AsyncImage` for loading thumbnails only when needed
- CoreData storage for keeping track of "Favourite" characters
- `.searchable()` modifier for character searching
