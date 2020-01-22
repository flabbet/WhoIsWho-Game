# Who is Who game

Who is who is a simple game that is used to learn names with simple flashcards system.

# Adding support for organization decks

## Logo
Open Android Studio or any text editor and navigate to assets folder, move your logo with name `logo.png` to this folder.

## Logo Requirements

Logo must be in png format.

Size doesn't matter that much however shape should be square for best result. You can use sizes like 100x100, 300x300 etc. But exceeding 500x500 is not necessary, since you won't see that many details anyway.

Sample logo can be found in assets folder


## Data
Now open `org.json`

Fill `domain` field using your organization domain.

Now if you store your deck in team shared Google Drive fill `file_id` field with id of deck file. Id can be found by: Right-click the file name and select Get shareable link. The last part of the link is the file ID

If you don't use Google Drive, then fill `deck_url` field with downloadable url to your deck.

Make sure to use either `file_id` or `deck_url`, not both. Delete one you are not using.

# Creating your own deck 

See [this detailed guide](https://github.com/flabbet/WhoIsWho-Game/wiki/Creating-your-own-deck)
