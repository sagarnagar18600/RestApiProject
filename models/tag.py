
# models/tag.py
from db import db
from models.item_tags import ItemTag

class TagModel(db.Model):
    __tablename__ = "tags"

    id   = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)
    store    = db.relationship("StoreModel", back_populates="tags")

    # Association object counterpart
    tag_items = db.relationship(
        "ItemTag",
        back_populates="tag",
        cascade="all, delete-orphan",
    )

    # Optional: convenience proxy to access ItemModel directly
    # from sqlalchemy.ext.associationproxy import association_proxy
    # items = association_proxy("tag_items", "item")
