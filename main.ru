import asyncio
import logging
from aiogram import Bot, Dispatcher, types, F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext

from config import BOT_TOKEN, ADMIN_ID, CHANNEL_ID
from database import Database
from states import AddProductStates, BroadcastStates, OrderStates
from keyboards import (
    get_main_keyboard,
    get_products_keyboard,
    get_admin_panel_keyboard,
    get_subscription_keyboard,
    get_confirm_delete_keyboard
)

logging.basicConfig(level=logging.INFO)
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()
db = Database()

async def is_subscribed(user_id: int) -> bool:
    try:
        member = await bot.get_chat_member(chat_id=CHANNEL_ID, user_id=user_id)
        return member.status in ["member", "administrator", "creator"]
    except:
        return False

@dp.message(Command("start"))
async def start_cmd(message: types.Message):
    is_admin = (message.from_user.id == ADMIN_ID)
    await message.answer(
        "👋 Добро пожаловать в Mooby Shop!\nЗдесь вы можете купить UC для PUBG Mobile.",
        reply_markup=get_main_keyboard(is_admin)
    )

@dp.message(F.text == "🛍 Купить UC")
async def buy_uc(message: types.Message, state: FSMContext):
    user_id = message.from_user.id
    if not await is_subscribed(user_id):
        await message.answer(
            f"❗ Для покупки подпишитесь на канал: {CHANNEL_ID}\nПосле подписки нажмите кнопку.",
            reply_markup=get_subscription_keyboard()
        )
        return
    products = await db.get_products()
    if not products:
        await message.answer("😕 Товаров пока нет.")
        return
    await message.answer("📦 Выберите товар:", reply_markup=get_products_keyboard(products))

@dp.callback_query(F.data == "check_subscription")
async def check_subscription(callback: types.CallbackQuery):
    user_id = callback.from_user.id
    if await is_subscribed(user_id):
        await callback.message.edit_text("✅ Подписка подтверждена! Выберите товар:")
        products = await db.get_products()
        if products:
            await callback.message.edit_reply_markup(reply_markup=get_products_keyboard(products))
        else:
            await callback.message.edit_text("😕 Товаров пока нет.")
    else:
        await callback.answer("❌ Вы не подписаны на канал!", show_alert=True)

@dp.callback_query(F.data.startswith("buy_"))
async def select_product(callback: types.CallbackQuery, state: FSMContext):
    product_id = int(callback.data.split("_")[1])
    product = await db.get_product(product_id)
    if not product:
        await callback.answer("Товар не найден", show_alert=True)
        return
    await state.update_data(
        product_id=product[0],
        product_name=product[1],
        price=product[2],
        uc_amount=product[3]
    )
    await callback.message.answer(
        f"Вы выбрали: {product[1]}\nЦена: {product[2]}₽\nUC: {product[3]}\n\nВведите ваш ID в PUBG (только цифры):"
    )
    await state.set_state(OrderStates.waiting_for_pubg_id)
    await callback.answer()

@dp.message(OrderStates.waiting_for_pubg_id)
async def process_pubg_id(message: types.Message, state: FSMContext):
    if not message.text.isdigit():
        await message.answer("❌ Введите только цифры. Попробуйте снова:")
        return
    data = await state.get_data()
    await db.add_order(
        user_id=message.from_user.id,
        username=message.from_user.username or "без username",
        product_id=data["product_id"],
        product_name=data["product_name"],
        price=data["price"],
        uc_amount=data["uc_amount"],
        pubg_id=message.text
    )
    await message.answer(
        f"✅ Заказ принят!\n"
        f"{data['product_name']} | {data['price']}₽ | {data['uc_amount']} UC\n"
        f"Ваш PUBG ID: {message.text}\n\n⏳ Ожидайте, скоро свяжется оператор."
    )
    await state.clear()

@dp.message(F.text == "📋 Мои заказы")
async def my_orders(message: types.Message):
    orders = await db.get_orders_by_user(message.from_user.id)
    if not orders:
        await message.answer("У вас пока нет заказов.")
        return
    text = "📋 *Ваши заказы:*\n\n"
    for order in orders[:10]:
        status_emoji = "✅" if order[5] == "completed" else "⏳"
        text += f"{status_emoji} {order[1]} | {order[2]}₽ | {order[3]} UC | ID: {order[4]}\n   {order[6]}\n\n"
    await message.answer(text, parse_mode="Markdown")

@dp.message(F.text == "⚙️ Админ-панель")
async def admin_panel(message: types.Message):
    if message.from_user.id != ADMIN_ID:
        await message.answer("⛔ Доступ запрещён.")
        return
    await message.answer("⚙️ Админ-панель:", reply_markup=get_admin_panel_keyboard())

@dp.callback_query(F.data == "admin_add_product")
async def admin_add_product(callback: types.CallbackQuery, state: FSMContext):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    await callback.message.answer("Введите название товара:")
    await state.set_state(AddProductStates.waiting_for_name)
    await callback.answer()

@dp.message(AddProductStates.waiting_for_name)
async def add_name(message: types.Message, state: FSMContext):
    await state.update_data(name=message.text)
    await message.answer("Введите цену (только цифры):")
    await state.set_state(AddProductStates.waiting_for_price)

@dp.message(AddProductStates.waiting_for_price)
async def add_price(message: types.Message, state: FSMContext):
    if not message.text.isdigit():
        await message.answer("❌ Введите число.")
        return
    await state.update_data(price=int(message.text))
    await message.answer("Введите количество UC (только цифры):")
    await state.set_state(AddProductStates.waiting_for_uc)

@dp.message(AddProductStates.waiting_for_uc)
async def add_uc(message: types.Message, state: FSMContext):
    if not message.text.isdigit():
        await message.answer("❌ Введите число.")
        return
    data = await state.get_data()
    await db.add_product(data["name"], data["price"], int(message.text))
    await message.answer(f"✅ Товар '{data['name']}' добавлен!")
    await state.clear()

@dp.callback_query(F.data == "admin_delete_product")
async def admin_delete_product(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    products = await db.get_products()
    if not products:
        await callback.message.answer("Список товаров пуст.")
        return
    builder = InlineKeyboardBuilder()
    for prod in products:
        builder.button(text=f"{prod[1]} ({prod[2]}₽, {prod[3]} UC)", callback_data=f"del_sel_{prod[0]}")
    builder.adjust(1)
    await callback.message.answer("Выберите товар для удаления:", reply_markup=builder.as_markup())
    await callback.answer()

@dp.callback_query(F.data.startswith("del_sel_"))
async def select_delete(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    product_id = int(callback.data.split("_")[2])
    product = await db.get_product(product_id)
    if not product:
        await callback.answer("Товар не найден", show_alert=True)
        return
    await callback.message.answer(
        f"Удалить товар '{product[1]}'?",
        reply_markup=get_confirm_delete_keyboard(product_id)
    )
    await callback.answer()

@dp.callback_query(F.data.startswith("confirm_delete_"))
async def confirm_delete(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    product_id = int(callback.data.split("_")[2])
    await db.delete_product(product_id)
    await callback.message.edit_text("✅ Товар удалён.")
    await callback.answer()

@dp.callback_query(F.data == "admin_cancel_delete")
async def cancel_delete(callback: types.CallbackQuery):
    await callback.message.edit_text("❌ Удаление отменено.")
    await callback.answer()

@dp.callback_query(F.data == "admin_list_products")
async def admin_list_products(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    products = await db.get_products()
    if not products:
        await callback.message.answer("📦 Товаров нет.")
    else:
        text = "📦 *Список товаров:*\n\n"
        for prod in products:
            text += f"ID {prod[0]}: {prod[1]} | {prod[2]}₽ | {prod[3]} UC\n"
        await callback.message.answer(text, parse_mode="Markdown")
    await callback.answer()

@dp.callback_query(F.data == "admin_all_orders")
async def admin_all_orders(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    orders = await db.get_all_orders(20)
    if not orders:
        await callback.message.answer("📋 Заказов пока нет.")
    else:
        text = "📋 *Последние заказы:*\n\n"
        for order in orders:
            status_emoji = "✅" if order[6] == "completed" else "⏳"
            text += f"#{order[0]} {status_emoji} {order[3]} | {order[4]}₽ | ID: {order[5]}\n   {order[2]} (ID {order[1]})\n   {order[7]}\n\n"
        await callback.message.answer(text, parse_mode="Markdown")
    await callback.answer()

@dp.callback_query(F.data == "admin_broadcast")
async def admin_broadcast(callback: types.CallbackQuery, state: FSMContext):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    await callback.message.answer("📢 Введите текст для рассылки (можно использовать Markdown):")
    await state.set_state(BroadcastStates.waiting_for_text)
    await callback.answer()

@dp.message(BroadcastStates.waiting_for_text)
async def broadcast_send(message: types.Message, state: FSMContext):
    if message.from_user.id != ADMIN_ID:
        return
    users = await db.get_all_users()
    if not users:
        await message.answer("Нет пользователей для рассылки.")
        await state.clear()
        return
    await message.answer(f"Начинаю рассылку для {len(users)} пользователей...")
    count = 0
    for uid in users:
        try:
            await bot.send_message(uid, message.text)
            count += 1
            await asyncio.sleep(0.05)
        except:
            pass
    await message.answer(f"✅ Рассылка завершена. Отправлено {count} сообщений.")
    await state.clear()

@dp.callback_query(F.data == "admin_exit")
async def admin_exit(callback: types.CallbackQuery):
    if callback.from_user.id != ADMIN_ID:
        await callback.answer("⛔ Доступ запрещён.", show_alert=True)
        return
    await callback.message.delete()
    await callback.message.answer(
        "Вы вышли из админ-панели.",
        reply_markup=get_main_keyboard(is_admin=True)
    )
    await callback.answer()

async def main():
    await db.create_tables()
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
