
# models/__init__.py
from db import db

from .item import ItemModel
from .tag import TagModel
from .item_tags import ItemTag     # ← file: itemtags.py, class: ItemTag
from .store import StoreModel
from .user import UserModel

__all__ = ["ItemModel", "TagModel", "ItemTag", "StoreModel", "UserModel"]
