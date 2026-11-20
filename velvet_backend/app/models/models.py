from datetime import datetime
from sqlalchemy import (
    Column, Integer, BigInteger, String, Text, Boolean, DateTime,
    Float, ForeignKey, Enum as SQLEnum, CheckConstraint, UniqueConstraint, Index
)
from sqlalchemy.orm import relationship
import enum

from app.core.database import Base


class ContentType(str, enum.Enum):
    PHOTO = "PHOTO"
    VIDEO = "VIDEO"
    COMIC = "COMIC"
    POST = "POST"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    telegram_id = Column(BigInteger, unique=True, index=True, nullable=False)
    username = Column(String(255), nullable=True)
    first_name = Column(String(255), nullable=True)
    language_code = Column(String(10), default="it")
    is_premium = Column(Boolean, default=False)
    balance_ov = Column(Float, default=0.0)          # $OV primaria
    balance_eur = Column(Float, default=0.0)         # Fiat secondaria
    created_at = Column(DateTime, default=datetime.utcnow)
    last_seen = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        CheckConstraint("balance_ov >= 0", name="ck_users_balance_ov_non_negative"),
        CheckConstraint("balance_eur >= 0", name="ck_users_balance_eur_non_negative"),
    )

    # Relations
    posts = relationship("Post", back_populates="author")
    generations = relationship("Generation", back_populates="user")
    donations_sent = relationship("Donation", foreign_keys="Donation.from_user_id", back_populates="from_user")
    donations_received = relationship("Donation", foreign_keys="Donation.to_user_id", back_populates="to_user")


class Generation(Base):
    """AGI generated content (photo / video / comic)"""
    __tablename__ = "generations"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    prompt = Column(Text, nullable=False)
    content_type = Column(SQLEnum(ContentType), nullable=False)
    style = Column(String(100), nullable=True)  # e.g. "Hardcore & La", "Noir 8K"
    format_ = Column(String(50), nullable=True)  # "Foto 8K Reali"
    status = Column(String(50), default="pending")  # pending, processing, completed, failed
    result_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="generations")


class Post(Base):
    """Creator posts in the Fan Hub"""
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True)
    author_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(300), nullable=False)
    description = Column(Text, nullable=True)
    media_url = Column(String(500), nullable=True)
    votes = Column(Integer, default=0)
    is_locked = Column(Boolean, default=False)  # for paying supporters
    created_at = Column(DateTime, default=datetime.utcnow)

    author = relationship("User", back_populates="posts")
    donations = relationship("Donation", back_populates="post")


class Donation(Base):
    __tablename__ = "donations"

    id = Column(Integer, primary_key=True)
    from_user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    to_user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    post_id = Column(Integer, ForeignKey("posts.id", ondelete="SET NULL"), nullable=True, index=True)
    amount_ov = Column(Float, default=0.0)           # $OV primaria
    amount_eur = Column(Float, default=0.0)
    currency = Column(String(10))  # OV or EUR
    status = Column(String(50), default="completed")
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        CheckConstraint("amount_ov >= 0", name="ck_donations_amount_ov_non_negative"),
        CheckConstraint("amount_eur >= 0", name="ck_donations_amount_eur_non_negative"),
        CheckConstraint(
            "(amount_ov > 0 AND amount_eur = 0) OR (amount_eur > 0 AND amount_ov = 0)",
            name="ck_donations_single_currency"
        ),
    )

    from_user = relationship("User", foreign_keys=[from_user_id], back_populates="donations_sent")
    to_user = relationship("User", foreign_keys=[to_user_id], back_populates="donations_received")
    post = relationship("Post", back_populates="donations")


class Match(Base):
    """Radar della Carne - 1km matchmaking"""
    __tablename__ = "matches"

    id = Column(Integer, primary_key=True)
    user_a_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    user_b_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    distance_km = Column(Float, nullable=True)
    status = Column(String(50), default="pending")  # pending, accepted, rejected
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        CheckConstraint("user_a_id < user_b_id", name="ck_matches_ordered_users"),
        UniqueConstraint("user_a_id", "user_b_id", name="uq_matches_pair"),
    )


class ChatMessage(Base):
    """Safe Chat / K.I.R.A. Shield"""
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True)
    room = Column(String(100), default="global")  # or private room id
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    message = Column(Text, nullable=False)
    is_system = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
