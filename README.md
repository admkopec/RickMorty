# Rick & Morty
A sample iOS application using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).
The application uses the [The Rick and Morty API](https://rickandmortyapi.com/documentation) to display list of characters and basic information about them.
## Features
- Infinite scroll pagination and `LazyVStack` for minimising the memory footprint of the application.
- `AsyncImage` for loading thumbnails only when needed
- CoreData storage for keeping track of "Favourite" characters
- `.searchable()` modifier for character searching
