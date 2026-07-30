extends Node

var score: float = 0
var add_score: int = 1
var passive_income: int = 0
var target_score: float = 10.0
var auto_timer_cost: float = 20.0
var rebirth_cost: float = 1000.0
var rebirth_count = 0
var rebirth_mult: float = 1.0


const SAVE_FILE_PATH = "user://savegame.json"

func save_game():
    var save_data = {
        "score": score,
        "add_score": add_score,
        "passive_income": passive_income,
        "target_score": target_score,
        "auto_timer_cost": auto_timer_cost,
        "rebirth_cost": rebirth_cost,
        "rebirth_count": rebirth_count,
        "rebirth_mult": rebirth_mult
    }
    var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(save_data)
        file.store_string(json_string)
        file.close()
        print("Data Saved!")

func load_game():
    if not FileAccess.file_exists(SAVE_FILE_PATH):
        print("No Save!")
        return

    var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()

        var json = JSON.new()
        var parse_result = json.parse(json_string)

        if parse_result == OK:
            var data = json.data

            score = data.get("score", score)
            add_score = data.get("add_score", add_score)
            passive_income = data.get("passive_income", passive_income)
            target_score = data.get("target_score", target_score)
            auto_timer_cost = data.get("auto_timer_cost", auto_timer_cost)
            rebirth_cost = data.get("rebirth_cost", rebirth_cost)
            rebirth_count = data.get("rebirth_count", rebirth_count)
            rebirth_mult = data.get("rebirth_mult", rebirth_mult)

            print("Loaded!")