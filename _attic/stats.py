from dataclasses import asdict, dataclass, field
from datetime import datetime

from google.cloud import firestore
from google.cloud.firestore import FieldFilter

print("Connecting to firestore...")
client = firestore.Client()
stats = client.collection("stats")
algorithms = client.collection("algorithms")
teams = client.collection("teams")


@dataclass
class Stat:
    team: str
    algorithm: str
    n: int
    result: int
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

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


def _document_to_stat(document) -> Stat:
    return Stat.from_dict(document.to_dict())
