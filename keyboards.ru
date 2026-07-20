from aiogram.types import ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardMarkup, InlineKeyboardButton
from aiogram.utils.keyboard import InlineKeyboardBuilder

def get_main_keyboard(is_admin=False):
    kb = [
        [KeyboardButton(text="🛍 Купить UC")],
        [KeyboardButton(text="📋 Мои заказы")]
    ]
    if is_admin:
        kb.append([KeyboardButton(text="⚙️ Админ-панель")])
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

def get_products_keyboard(products):
    builder = InlineKeyboardBuilder()
    for prod in products:
        builder.button(text=f"{prod[1]} | {prod[2]}₽ | {prod[3]} UC", callback_data=f"buy_{prod[0]}")
    builder.adjust(1)
    return builder.as_markup()

def get_admin_panel_keyboard():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="➕ Добавить товар", callback_data="admin_add_product")],
        [InlineKeyboardButton(text="❌ Удалить товар", callback_data="admin_delete_product")],
        [InlineKeyboardButton(text="📦 Список товаров", callback_data="admin_list_products")],
        [InlineKeyboardButton(text="📋 Все заказы", callback_data="admin_all_orders")],
        [InlineKeyboardButton(text="📢 Рассылка", callback_data="admin_broadcast")],
        [InlineKeyboardButton(text="◀️ Выйти", callback_data="admin_exit")]
    ])

def get_subscription_keyboard():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✅ Я подписался", callback_data="check_subscription")]
    ])

def get_confirm_delete_keyboard(product_id):
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✅ Да, удалить", callback_data=f"confirm_delete_{product_id}"),
         InlineKeyboardButton(text="❌ Отмена", callback_data="admin_cancel_delete")]
    ])
