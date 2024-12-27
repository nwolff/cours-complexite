# But

Une application web avec rien à installer sur le client, et pas de runtime sur le serveur.
Les algorithmes tournent dans les navigateurs des élèves. Les statistiques sont stockées comme d'habitude sur firestore

# Deux applications

- Une application web pour les élèves et l'enseignant. Voir [elm/README.md](elm/README.md)
- Une application cli pour l'enseignant. Voir [python/README.md](python/README.md)

# Théorie

ok cool. but now it seems in the stats that quicksort is worst than merge

This is actually mathematically correct. Merge sort makes fewer comparisons than quicksort on average:

Quicksort (random pivot, first element): ~2·n·ln(n) ≈ 1.39·n·log₂(n) comparisons
Merge sort: ~n·log₂(n) comparisons (with early termination when one half is exhausted)
For n=1000, you'd expect roughly ~13,800 vs ~10,000. Quicksort genuinely does more comparisons — it's just faster in practice because of cache locality and in-place swaps, not comparison count.

So for a complexity course this is actually a nice observation: both are O(n log n), but with different constants. Is this what you want to show students, or would you prefer to count a different operation (like swaps/writes) where quicksort would look better?
