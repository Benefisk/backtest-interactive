# Точка входа настольного приложения: считает бэктест и показывает
# интерактивный график (web/chart.html) в окне pywebview.
# Сборка в exe: PyInstaller (см. build_exe.bat); данные и веб-ресурсы
# подключаются через --add-data, а путь к ним находится через sys._MEIPASS.
import sys
import traceback
from pathlib import Path

import webview

import main as bt

# Если запущено из PyInstaller-бандла, ресурсы лежат во временной папке
# sys._MEIPASS (onedir: это папка _internal рядом с exe); иначе — рядом с app.py.
if getattr(sys, "frozen", False):
    RESOURCE_DIR = Path(sys._MEIPASS)
else:
    RESOURCE_DIR = Path(__file__).resolve().parent

WEB_DIR = RESOURCE_DIR / "web"
CHART_HTML = WEB_DIR / "chart.html"

ERROR_HTML = """<!DOCTYPE html>
<html lang="ru">
<head><meta charset="UTF-8"><title>Ошибка бэктеста</title>
<style>
    body {{ background: #131722; color: #d1d4dc; font-family: Arial, sans-serif;
           padding: 24px; white-space: pre-wrap; }}
    h2 {{ color: #ff5252; }}
</style></head>
<body>
<h2>Не удалось выполнить бэктест</h2>
<div>{message}</div>
</body></html>
"""


def run_pipeline():
    """Полный цикл как в main(): котировки → бэктест → сводка → данные графика."""

    prices = bt.load_prices()
    results = bt.run_backtest(prices)
    stats_text, trade_log = bt.build_stats(results)

    # Данные пишем рядом с chart.html, чтобы страница подхватила их
    # относительным путём при загрузке через file://.
    bt.CHART_DATA_FILE = WEB_DIR / "chart_data.js"
    bt.export_chart_data(results, stats_text, trade_log)

    return results


def main():
    try:
        run_pipeline()
        window = webview.create_window(
            "Бэктест стратегии SMA",
            url=CHART_HTML.resolve().as_uri(),
            width=1320,
            height=880,
        )
    except Exception:
        # Ошибку показываем в окне, а не молча падаем (приложение без консоли).
        window = webview.create_window(
            "Бэктест стратегии SMA — ошибка",
            html=ERROR_HTML.format(message=traceback.format_exc()),
            width=1320,
            height=880,
        )

    webview.start()


if __name__ == "__main__":
    main()
