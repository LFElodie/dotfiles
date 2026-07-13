import subprocess

import ranger.api
from ranger.api.commands import Command


HOOK_INIT_OLD = ranger.api.hook_init


def hook_init(fm):
    def update_zoxide(signal):
        subprocess.Popen(
            ["zoxide", "add", signal.new.path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    fm.signal_bind("cd", update_zoxide)
    HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init


class j(Command):
    """:j

    使用 zoxide 查询并切换目录。
    """

    def execute(self):
        try:
            directory = subprocess.check_output(
                ["zoxide", "query", "--", self.arg(1)],
                text=True,
            ).rstrip("\n")
        except (FileNotFoundError, subprocess.CalledProcessError):
            self.fm.notify("zoxide 未找到匹配目录", bad=True)
            return

        self.fm.cd(directory)
