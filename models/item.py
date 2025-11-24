
# models/item.py
from db import db
from models.item_tags import ItemTag

class ItemModel(db.Model):
    __tablename__ = "items"

    id    = db.Column(db.Integer, primary_key=True)
    name  = db.Column(db.String(80), nullable=False)
    price = db.Column(db.Float(precision=2), nullable=False)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)
    store    = db.relationship("StoreModel", back_populates="items")

    # Association object (link rows)
    item_tags = db.relationship(
        "ItemTag",
        back_populates="item",
        cascade="all, delete-orphan",
    )

    # Optional: convenience proxy to access TagModel directly
    # from sqlalchemy.ext.associationproxy import association_proxy
    # tags = association_proxy("item_tags", "tag")
