"""referential_integrity

Revision ID: 1fdfc3a8cc76
Revises: 5d4d1c7ee665
Create Date: 2026-11-12 13:56:12.083359

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '1fdfc3a8cc76'
down_revision: Union[str, Sequence[str], None] = '5d4d1c7ee665'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- Check constraints ---
    op.create_check_constraint(
        "ck_users_balance_ov_non_negative",
        "users",
        "balance_ov >= 0",
    )
    op.create_check_constraint(
        "ck_users_balance_eur_non_negative",
        "users",
        "balance_eur >= 0",
    )
    op.create_check_constraint(
        "ck_donations_amount_ov_non_negative",
        "donations",
        "amount_ov >= 0",
    )
    op.create_check_constraint(
        "ck_donations_amount_eur_non_negative",
        "donations",
        "amount_eur >= 0",
    )
    op.create_check_constraint(
        "ck_donations_single_currency",
        "donations",
        "(amount_ov > 0 AND amount_eur = 0) OR (amount_eur > 0 AND amount_ov = 0)",
    )
    op.create_check_constraint(
        "ck_matches_ordered_users",
        "matches",
        "user_a_id < user_b_id",
    )

    # --- Unique constraint on match pairs ---
    op.create_unique_constraint("uq_matches_pair", "matches", ["user_a_id", "user_b_id"])

    # --- Drop old FKs and recreate with ON DELETE ---
    # generations
    op.drop_constraint("generations_user_id_fkey", "generations", type_="foreignkey")
    op.create_foreign_key(
        "generations_user_id_fkey", "generations", "users",
        ["user_id"], ["id"], ondelete="CASCADE"
    )

    # posts
    op.drop_constraint("posts_author_id_fkey", "posts", type_="foreignkey")
    op.create_foreign_key(
        "posts_author_id_fkey", "posts", "users",
        ["author_id"], ["id"], ondelete="CASCADE"
    )

    # donations
    op.drop_constraint("donations_from_user_id_fkey", "donations", type_="foreignkey")
    op.drop_constraint("donations_to_user_id_fkey", "donations", type_="foreignkey")
    op.drop_constraint("donations_post_id_fkey", "donations", type_="foreignkey")
    op.create_foreign_key(
        "donations_from_user_id_fkey", "donations", "users",
        ["from_user_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "donations_to_user_id_fkey", "donations", "users",
        ["to_user_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "donations_post_id_fkey", "donations", "posts",
        ["post_id"], ["id"], ondelete="SET NULL"
    )

    # matches
    op.drop_constraint("matches_user_a_id_fkey", "matches", type_="foreignkey")
    op.drop_constraint("matches_user_b_id_fkey", "matches", type_="foreignkey")
    op.create_foreign_key(
        "matches_user_a_id_fkey", "matches", "users",
        ["user_a_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "matches_user_b_id_fkey", "matches", "users",
        ["user_b_id"], ["id"], ondelete="CASCADE"
    )

    # chat_messages
    op.drop_constraint("chat_messages_user_id_fkey", "chat_messages", type_="foreignkey")
    op.create_foreign_key(
        "chat_messages_user_id_fkey", "chat_messages", "users",
        ["user_id"], ["id"], ondelete="CASCADE"
    )

    # --- Indexes on FK columns (performance + integrity) ---
    op.create_index("ix_generations_user_id", "generations", ["user_id"])
    op.create_index("ix_posts_author_id", "posts", ["author_id"])
    op.create_index("ix_donations_from_user_id", "donations", ["from_user_id"])
    op.create_index("ix_donations_to_user_id", "donations", ["to_user_id"])
    op.create_index("ix_donations_post_id", "donations", ["post_id"])
    op.create_index("ix_matches_user_a_id", "matches", ["user_a_id"])
    op.create_index("ix_matches_user_b_id", "matches", ["user_b_id"])
    op.create_index("ix_chat_messages_user_id", "chat_messages", ["user_id"])


def downgrade() -> None:
    # Drop indexes
    op.drop_index("ix_chat_messages_user_id", table_name="chat_messages")
    op.drop_index("ix_matches_user_b_id", table_name="matches")
    op.drop_index("ix_matches_user_a_id", table_name="matches")
    op.drop_index("ix_donations_post_id", table_name="donations")
    op.drop_index("ix_donations_to_user_id", table_name="donations")
    op.drop_index("ix_donations_from_user_id", table_name="donations")
    op.drop_index("ix_posts_author_id", table_name="posts")
    op.drop_index("ix_generations_user_id", table_name="generations")

    # Restore simple FKs (no ON DELETE)
    op.drop_constraint("chat_messages_user_id_fkey", "chat_messages", type_="foreignkey")
    op.create_foreign_key("chat_messages_user_id_fkey", "chat_messages", "users", ["user_id"], ["id"])

    op.drop_constraint("matches_user_b_id_fkey", "matches", type_="foreignkey")
    op.drop_constraint("matches_user_a_id_fkey", "matches", type_="foreignkey")
    op.create_foreign_key("matches_user_a_id_fkey", "matches", "users", ["user_a_id"], ["id"])
    op.create_foreign_key("matches_user_b_id_fkey", "matches", "users", ["user_b_id"], ["id"])

    op.drop_constraint("donations_post_id_fkey", "donations", type_="foreignkey")
    op.drop_constraint("donations_to_user_id_fkey", "donations", type_="foreignkey")
    op.drop_constraint("donations_from_user_id_fkey", "donations", type_="foreignkey")
    op.create_foreign_key("donations_from_user_id_fkey", "donations", "users", ["from_user_id"], ["id"])
    op.create_foreign_key("donations_to_user_id_fkey", "donations", "users", ["to_user_id"], ["id"])
    op.create_foreign_key("donations_post_id_fkey", "donations", "posts", ["post_id"], ["id"])

    op.drop_constraint("posts_author_id_fkey", "posts", type_="foreignkey")
    op.create_foreign_key("posts_author_id_fkey", "posts", "users", ["author_id"], ["id"])

    op.drop_constraint("generations_user_id_fkey", "generations", type_="foreignkey")
    op.create_foreign_key("generations_user_id_fkey", "generations", "users", ["user_id"], ["id"])

    # Drop unique + checks
    op.drop_constraint("uq_matches_pair", "matches", type_="unique")
    op.drop_constraint("ck_matches_ordered_users", "matches", type_="check")
    op.drop_constraint("ck_donations_single_currency", "donations", type_="check")
    op.drop_constraint("ck_donations_amount_eur_non_negative", "donations", type_="check")
    op.drop_constraint("ck_donations_amount_ov_non_negative", "donations", type_="check")
    op.drop_constraint("ck_users_balance_eur_non_negative", "users", type_="check")
    op.drop_constraint("ck_users_balance_ov_non_negative", "users", type_="check")
