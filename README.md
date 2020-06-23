# anagrams

A static webpage designed to aid in playing the popular word game [Anagrams](https://en.wikipedia.org/wiki/Anagrams).

Try it out [here](https://rubinmarty.github.io/anagrams/).
  
### Usage

Simply enter any combination of letters into the search box, and you will be provided with any words
that can be made using those letters. The page for each word also provides information on
easy ways to "steal" that word from another player by adding 1-3 additional letters.

### Details

Because the entire application runs in the browser, there is an initial ~5 second load time during which
the browser must parse the ~300,000 word dictionary. Subsequent word searches during the same session are
nearly instantaneous.

The reference dictionary is Collins Scrabble Words (2019).
