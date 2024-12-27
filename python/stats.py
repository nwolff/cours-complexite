from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone

from google.cloud import firestore
from google.cloud.firestore import FieldFilter

print("Connecting to firestore...")
client = firestore.Client(database="cours-complexite")
stats = client.collection("stats")
algorithms = client.collection("algorithms")
teams = client.collection("teams")


@dataclass
class Stat:
    team: str
    algorithm: str
    n: int
    result: int
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    @staticmethod
    def from_dict(source):
        return Stat(**source)

    def to_dict(self):
        return asdict(self)


def all_algorithms() -> list[str]:
    return [a.id for a in algorithms.stream()]


def all_teams() -> list[str]:
    return [t.id for t in teams.stream()]


def all_stats(team: str = "", algorithm: str = "") -> list[Stat]:
    q = stats
    if team:
        q = q.where(filter=FieldFilter("team", "==", team))
    if algorithm:
        q = q.where(filter=FieldFilter("algorithm", "==", algorithm))
    return [_document_to_stat(doc) for doc in q.stream()]


def insert_stat(stat: Stat) -> None:
    stats.add(stat.to_dict())
    algorithms.document(stat.algorithm).set({})
    teams.document(stat.team).set({})


def insert_stats_batch(stat_list: list[Stat]) -> None:
    if not stat_list:
        return

    # Firestore batch limit is 500 ops; use 400 to stay safe.
    batch_size = 400
    for i in range(0, len(stat_list), batch_size):
        batch = client.batch()
        for stat in stat_list[i : i + batch_size]:
            batch.set(stats.document(), stat.to_dict())
        batch.commit()

    # Update the algorithm/team registries once, deduplicated.
    reg_batch = client.batch()
    for name in {s.algorithm for s in stat_list}:
        reg_batch.set(algorithms.document(name), {})
    for name in {s.team for s in stat_list}:
        reg_batch.set(teams.document(name), {})
    reg_batch.commit()


def _document_to_stat(document) -> Stat:
    return Stat.from_dict(document.to_dict())
