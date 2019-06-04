#
# * ReaScript Name: HelloWwise
# * Description: 
# * Instructions: 
# * Author: Simon Gumbleton
# * Version: 1.0
#


import os
import sys

import asyncio

from autobahn.asyncio.wamp import ApplicationSession, ApplicationRunner

# You may also copy-paste the waapi.py file alongside this sample
#sys.path.append(os.path.join(os.path.dirname(__file__), '../../../../include/AK/WwiseAuthoringAPI/py'))
from waapi import WAAPI_URI

from reaper_python import *


class MyComponent(ApplicationSession):
    runFromReaper = True


    def onJoin(self, details):
        #RPR_ShowConsoleMsg("Got to on Join")
        try:
            res = yield from(self.call(WAAPI_URI.ak_wwise_core_getinfo)) # RPC call without arguments
        except Exception as ex:
            print("call error: {}".format(ex))
        else:
            # Call was successful, displaying information from the payload.
            print("Hello {} {}".format(res.kwresults['displayName'], res.kwresults['version']['displayName']))
            if MyComponent.runFromReaper:
                RPR_ShowConsoleMsg("Hello {} {}".format(res.kwresults['displayName'], res.kwresults['version']['displayName']))

        self.leave()

    def onDisconnect(self):
        RPR_ShowConsoleMsg("Got to on Disconnect")
        # print("The client was disconnected.")
        asyncio.get_event_loop().stop()

if __name__ == '__main__':
    #RPR_ShowConsoleMsg("Hello Reaper...")
    runner = ApplicationRunner(url=u"ws://127.0.0.1:8095/waapi", realm=u"realm1")
    try:
        runner.run(MyComponent)
    except Exception as e:
        print(type(e).__name__ + ": Is Wwise running and Wwise Authoring API enabled?")

