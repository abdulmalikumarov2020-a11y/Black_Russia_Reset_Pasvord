from aiogram.fsm.state import State, StatesGroup

class AddProductStates(StatesGroup):
    waiting_for_name = State()
    waiting_for_price = State()
    waiting_for_uc = State()

class BroadcastStates(StatesGroup):
    waiting_for_text = State()

class OrderStates(StatesGroup):
    waiting_for_pubg_id = State()
