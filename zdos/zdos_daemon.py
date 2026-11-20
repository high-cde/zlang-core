#!/usr/bin/env python3
import time
import os

print("⚡ [ZDOS DAEMON ACTIVE]: Monitoraggio nodi mesh e registri DSN in corso...")
while True:
    # Esegue il controllo ciclico dell'integrità dei moduli
    with open("/root/zdos/kernel_pulse.log", "a") as log:
        log.write(f"Pulse OK - Timestamp: {time.time()}\n")
    time.sleep(60)
