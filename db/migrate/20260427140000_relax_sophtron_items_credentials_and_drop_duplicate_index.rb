class RelaxSophtronItemsCredentialsAndDropDuplicateIndex < ActiveRecord::Migration[7.2]
  def up
    # user_id and access_key are optional credentials filled later during OAuth/setup flow.
    # The original schema on main incorrectly showed them as null: false; relax here
    # so migrated DBs match the intended schema.
    change_column_null :sophtron_items, :user_id, true
    change_column_null :sophtron_items, :access_key, true

    # The unique composite index was present on main but was never added via an explicit
    # migration — it was a schema artefact. Drop it so migrated and schema-loaded DBs agree.
    remove_index :sophtron_accounts,
                 name: :idx_unique_sophtron_accounts_per_item,
                 if_exists: true
  end

  def down
    change_column_null :sophtron_items, :user_id, false
    change_column_null :sophtron_items, :access_key, false

    add_index :sophtron_accounts,
              %i[sophtron_item_id account_id],
              name: :idx_unique_sophtron_accounts_per_item,
              unique: true,
              if_not_exists: true
  end
end
