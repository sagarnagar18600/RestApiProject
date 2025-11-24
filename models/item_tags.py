
# models/itemtags.py
from db import db

class ItemTag(db.Model):
    __tablename__ = "items_tags"

    item_id = db.Column(db.Integer, db.ForeignKey("items.id"), primary_key=True)
    tag_id  = db.Column(db.Integer, db.ForeignKey("tags.id"), primary_key=True)

    # Optional extra fields if you need them:
    # created_at = db.Column(db.DateTime, server_default=db.func.now())
    # added_by   = db.Column(db.String(64))

    # Relationships back to Item and Tag
    item = db.relationship("ItemModel", back_populates="item_tags")
    tag  = db.relationship("TagModel",  back_populates="tag_items")
