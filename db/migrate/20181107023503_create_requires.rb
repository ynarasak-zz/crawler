class CreateRequires < ActiveRecord::Migration[5.2]
  def change
    create_table :requires do |t|
      t.string :word

      t.timestamps
    end
  end
end
