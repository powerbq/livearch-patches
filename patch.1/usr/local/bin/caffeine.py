#!/usr/bin/python3

import os
import signal
import subprocess
import threading
import time

import gi

gi.require_version('Wnck', '3.0')
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')

from gi.repository import Wnck, Gtk, AppIndicator3


class Caffeine:

    def event_opened(self, screen, window):
        window.connect('geometry-changed', self.event_resized)

    def event_changed(self, screen, window):
        self.process_fullscreen(window)

    def event_resized(self, window):
        self.process_fullscreen(window)

    def event_lock_toggle(self, item, lock):
        self.update_all(lock=lock)

    def event_exit(self, item):
        os.kill(os.getpid(), signal.SIGINT)

    def process_fullscreen(self, window):
        if window is None:
            return

        switch = False
        disable = window.is_fullscreen()
        if disable:
            switch = True

        if switch != self.dpms_disabled and not self.locked:
            self.update_all(disable=disable)

    def change_dpms_state(self, disable):
        cmd = 'xset|-dpms'
        if not disable:
            cmd = 'xset|+dpms'

        subprocess.call(cmd.split('|'))
        cmd = 'xset|s|off'
        subprocess.call(cmd.split('|'))

    def update_all(self, lock=None, disable=None):
        if disable is None:
            disable = self.dpms_disabled

        if lock is None:
            lock = self.locked
        else:
            disable = lock

        self.dpms_disabled = disable
        self.locked = lock

        self.change_dpms_state(disable)
        self.update_menu()
        self.update_indicator()

    def update_menu(self):
        self.menu.remove(self.menu_lock)
        self.menu.remove(self.menu_restore)
        self.menu.remove(self.menu_exit)

        if self.locked:
            self.menu.append(self.menu_restore)
        else:
            self.menu.append(self.menu_lock)

        self.menu.append(self.menu_exit)
        self.menu.show_all()

    def update_indicator(self):
        if self.locked:
            self.indicator.set_icon('locked')

            return

        self.indicator.set_icon('caffeine-cup-{}'.format('full' if self.dpms_disabled else 'empty'))

    def worker(self):
        time.sleep(self.indicator_update_interval)

        self.update_all()

    def run(self):
        thread = threading.Thread(target=self.worker)
        thread.start()

        Gtk.main()

    def __init__(self):
        self.menu = Gtk.Menu()

        self.locked = False
        self.dpms_disabled = False

        self.indicator_update_interval = 15
        self.indicator = AppIndicator3.Indicator.new('caffeine', 'locked', AppIndicator3.IndicatorCategory.SYSTEM_SERVICES)
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.menu)

        self.menu_lock = Gtk.MenuItem('Заблокировать выключение экрана')
        self.menu_restore = Gtk.MenuItem('Вернуться в автоматический режим')
        self.menu_exit = Gtk.MenuItem('Закрыть программу')
        self.menu_lock.connect("activate", self.event_lock_toggle, True)
        self.menu_restore.connect("activate", self.event_lock_toggle, False)
        self.menu_exit.connect("activate", self.event_exit)

        screen = Wnck.Screen.get_default()
        screen.connect('window-opened', self.event_opened)
        screen.connect('active-window-changed', self.event_changed)

        windows = screen.get_windows()
        for window in windows:
            self.event_opened(screen, window)

        self.update_all()


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    base = Caffeine()
    base.run()
