import aiosqlite

class Database:
    def __init__(self, db_file="database.db"):
        self.db_file = db_file

    async def create_tables(self):
        async with aiosqlite.connect(self.db_file) as db:
            await db.execute('''
                CREATE TABLE IF NOT EXISTS products (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    price INTEGER NOT NULL,
                    uc_amount INTEGER NOT NULL
                )
            ''')
            await db.execute('''
                CREATE TABLE IF NOT EXISTS orders (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    username TEXT,
                    product_id INTEGER,
                    product_name TEXT,
                    price INTEGER,
                    uc_amount INTEGER,
                    pubg_id TEXT NOT NULL,
                    status TEXT DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            await db.commit()

    async def add_product(self, name, price, uc_amount):
        async with aiosqlite.connect(self.db_file) as db:
            await db.execute("INSERT INTO products (name, price, uc_amount) VALUES (?, ?, ?)",
                             (name, price, uc_amount))
            await db.commit()

    async def delete_product(self, product_id):
        async with aiosqlite.connect(self.db_file) as db:
            await db.execute("DELETE FROM products WHERE id = ?", (product_id,))
            await db.commit()

    async def get_products(self):
        async with aiosqlite.connect(self.db_file) as db:
            cursor = await db.execute("SELECT id, name, price, uc_amount FROM products")
            return await cursor.fetchall()

    async def get_product(self, product_id):
        async with aiosqlite.connect(self.db_file) as db:
            cursor = await db.execute("SELECT id, name, price, uc_amount FROM products WHERE id = ?", (product_id,))
            return await cursor.fetchone()

    async def add_order(self, user_id, username, product_id, product_name, price, uc_amount, pubg_id):
        async with aiosqlite.connect(self.db_file) as db:
            await db.execute(
                "INSERT INTO orders (user_id, username, product_id, product_name, price, uc_amount, pubg_id) "
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                (user_id, username, product_id, product_name, price, uc_amount, pubg_id)
            )
            await db.commit()

    async def get_orders_by_user(self, user_id):
        async with aiosqlite.connect(self.db_file) as db:
            cursor = await db.execute(
                "SELECT id, product_name, price, uc_amount, pubg_id, status, created_at "
                "FROM orders WHERE user_id = ? ORDER BY created_at DESC",
                (user_id,)
            )
            return await cursor.fetchall()

    async def get_all_orders(self, limit=50):
        async with aiosqlite.connect(self.db_file) as db:
            cursor = await db.execute(
                "SELECT id, user_id, username, product_name, price, pubg_id, status, created_at "
                "FROM orders ORDER BY created_at DESC LIMIT ?",
                (limit,)
            )
            return await cursor.fetchall()

    async def get_all_users(self):
        async with aiosqlite.connect(self.db_file) as db:
            cursor = await db.execute("SELECT DISTINCT user_id FROM orders")
            rows = await cursor.fetchall()
            return [row[0] for row in rows]
