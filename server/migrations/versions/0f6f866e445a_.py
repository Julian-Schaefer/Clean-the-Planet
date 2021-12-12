"""empty message

Revision ID: 0f6f866e445a
Revises: 76d2f42d02c2
Create Date: 2021-10-06 16:51:13.367265

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '0f6f866e445a'
down_revision = '76d2f42d02c2'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    # op.drop_table('spatial_ref_sys')
    op.add_column(
        'tour',
        sa.Column('result_picture_keys',
                  postgresql.JSONB(astext_type=sa.Text()),
                  nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('tour', 'result_picture_keys')
    op.create_table(
        'spatial_ref_sys',
        sa.Column('srid', sa.INTEGER(), autoincrement=False, nullable=False),
        sa.Column('auth_name',
                  sa.VARCHAR(length=256),
                  autoincrement=False,
                  nullable=True),
        sa.Column('auth_srid',
                  sa.INTEGER(),
                  autoincrement=False,
                  nullable=True),
        sa.Column('srtext',
                  sa.VARCHAR(length=2048),
                  autoincrement=False,
                  nullable=True),
        sa.Column('proj4text',
                  sa.VARCHAR(length=2048),
                  autoincrement=False,
                  nullable=True),
        sa.CheckConstraint('(srid > 0) AND (srid <= 998999)',
                           name='spatial_ref_sys_srid_check'),
        sa.PrimaryKeyConstraint('srid', name='spatial_ref_sys_pkey'))
    # ### end Alembic commands ###
