/** @file
 *
 *  Differentiated System Definition Table (DSDT)
 *
 *  Copyright (c) 2020, Pete Batard <pete@akeo.ie>
 *  Copyright (c) 2018-2020, Andrey Warkentin <andrey.warkentin@gmail.com>
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *
 *  SPDX-License-Identifier: BSD-2-Clause-Patent
 *
 **/

#include <IndustryStandard/Bcm2711.h>
#include <IndustryStandard/Bcm2836.h>
#include <IndustryStandard/Bcm2836Gpio.h>
#include <IndustryStandard/Bcm2836Gpu.h>
#include <IndustryStandard/Bcm2836Pwm.h>
#include <IndustryStandard/Bcm2836Sdio.h>
#include <IndustryStandard/Bcm2836SdHost.h>

#include "AcpiTables.h"

#define BCM_ALT0 0x4
#define BCM_ALT1 0x5
#define BCM_ALT2 0x6
#define BCM_ALT3 0x7
#define BCM_ALT4 0x3
#define BCM_ALT5 0x2

#define GPIO_PIN 19

//
// The ASL compiler does not support argument arithmetic in functions
// like QWordMemory (). So we need to instantiate dummy qword regions
// that we can then update the Min, Max and Length attributes of.
// The three macros below help accomplish this.
//
// QWORDMEMORYSET specifies a CPU memory range (whose base address is
// BCM2836_SOC_REGISTERS + Offset), and QWORDBUSMEMORYSET specifies
// a VPU memory range (whose base address is provided directly).
//
#define QWORDMEMORYBUF(Index)                                   \
  QWordMemory (ResourceProducer,,                               \
    MinFixed, MaxFixed, NonCacheable, ReadWrite,                \
    0x0, 0x0, 0x0, 0x0, 0x1,,, RB ## Index)

#define QWORDMEMORYSET(Index, Offset, Length)                   \
  CreateQwordField (RBUF, RB ## Index._MIN, MI ## Index)        \
  CreateQwordField (RBUF, RB ## Index._MAX, MA ## Index)        \
  CreateQwordField (RBUF, RB ## Index._LEN, LE ## Index)        \
  Store (Length, LE ## Index)                                   \
  Add (BCM2836_SOC_REGISTERS, Offset, MI ## Index)              \
  Add (MI ## Index, LE ## Index - 1, MA ## Index)

#define QWORDBUSMEMORYSET(Index, Base, Length)                  \
  CreateQwordField (RBUF, RB ## Index._MIN, MI ## Index)        \
  CreateQwordField (RBUF, RB ## Index._MAX, MA ## Index)        \
  CreateQwordField (RBUF, RB ## Index._LEN, LE ## Index)        \
  Store (Base, MI ## Index)                                     \
  Store (Length, LE ## Index)                                   \
  Add (MI ## Index, LE ## Index - 1, MA ## Index)

DefinitionBlock ("Dsdt.aml", "DSDT", 5, "RPIFDN", "RPI", 2)
{
  Scope (\_SB_)
  {
    include ("Pep.asl")
#if (RPI_MODEL == 4)
    include ("Xhci.asl")
#endif

    Device (CPU0)
    {
      Name (_HID, "ACPI0007")
      Name (_UID, 0x0)
      Method (_STA)
      {
        Return (0xf)
      }
    }

    Device (CPU1)
    {
      Name (_HID, "ACPI0007")
      Name (_UID, 0x1)
      Method (_STA)
      {
        Return (0xf)
      }
    }

    Device (CPU2)
    {
      Name (_HID, "ACPI0007")
      Name (_UID, 0x2)
      Method (_STA)
      {
        Return (0xf)
      }
    }

    Device (CPU3)
    {
      Name (_HID, "ACPI0007")
      Name (_UID, 0x3)
      Method (_STA)
      {
        Return (0xf)
      }
    }

    //
    // GPU device container describes the DMA translation required
    // when a device behind the GPU wants to access Arm memory.
    // Only the first GB can be addressed.
    //
    Device (GDV0)
    {
      Name (_HID, "ACPI0004")
      Name (_UID, 0x1)
      Name (_CCA, 0x0)

      Method (_CRS, 0, Serialized) {
        //
        // Container devices with _DMA must have _CRS, meaning GDV0
        // to provide all resources that GpuDevs.asl consume (except
        // interrupts).
        //
        Name (RBUF, ResourceTemplate () {
          QWORDMEMORYBUF(01)
          QWORDMEMORYBUF(02)
          QWORDMEMORYBUF(03)
          // QWORDMEMORYBUF(04)
          // QWORDMEMORYBUF(05)
          QWORDMEMORYBUF(06)
          QWORDMEMORYBUF(07)
          QWORDMEMORYBUF(08)
          QWORDMEMORYBUF(09)
          QWORDMEMORYBUF(10)
          QWORDMEMORYBUF(11)
          QWORDMEMORYBUF(12)
          QWORDMEMORYBUF(13)
          QWORDMEMORYBUF(14)
          QWORDMEMORYBUF(15)
          // QWORDMEMORYBUF(16)
          QWORDMEMORYBUF(17)
          QWORDMEMORYBUF(18)
          QWORDMEMORYBUF(19)
          QWORDMEMORYBUF(20)
          QWORDMEMORYBUF(21)
          QWORDMEMORYBUF(22)
          QWORDMEMORYBUF(23)
          QWORDMEMORYBUF(24)
          QWORDMEMORYBUF(25)
        })

        // USB
        QWORDMEMORYSET(01, BCM2836_USB_OFFSET, BCM2836_USB_LENGTH)

        // GPU
        QWORDMEMORYSET(02, BCM2836_V3D_BUS_OFFSET, BCM2836_V3D_BUS_LENGTH)
        QWORDMEMORYSET(03, BCM2836_HVS_OFFSET, BCM2836_HVS_LENGTH)
        // QWORDMEMORYSET(04, BCM2836_PV0_OFFSET, BCM2836_PV0_LENGTH)
        // QWORDMEMORYSET(05, BCM2836_PV1_OFFSET, BCM2836_PV1_LENGTH)
        QWORDMEMORYSET(06, BCM2836_PV2_OFFSET, BCM2836_PV2_LENGTH)
        QWORDMEMORYSET(07, BCM2836_HDMI0_OFFSET, BCM2836_HDMI0_LENGTH)
        QWORDMEMORYSET(08, BCM2836_HDMI1_OFFSET, BCM2836_HDMI1_LENGTH)

        // Mailbox
        QWORDMEMORYSET(09, BCM2836_MBOX_OFFSET, BCM2836_MBOX_LENGTH)

        // VCHIQ
        QWORDMEMORYSET(10, BCM2836_VCHIQ_OFFSET, BCM2836_VCHIQ_LENGTH)

        // GPIO
        QWORDMEMORYSET(11, GPIO_OFFSET, GPIO_LENGTH)

        // I2C
        QWORDMEMORYSET(12, BCM2836_I2C1_OFFSET, BCM2836_I2C1_LENGTH)
        QWORDMEMORYSET(13, BCM2836_I2C2_OFFSET, BCM2836_I2C2_LENGTH)

        // SPI
        QWORDMEMORYSET(14, BCM2836_SPI0_OFFSET, BCM2836_SPI0_LENGTH)
        QWORDMEMORYSET(15, BCM2836_SPI1_OFFSET, BCM2836_SPI1_LENGTH)
        // QWORDMEMORYSET(16, BCM2836_SPI2_OFFSET, BCM2836_SPI2_LENGTH)

        // PWM
        QWORDMEMORYSET(17, BCM2836_PWM_DMA_OFFSET, BCM2836_PWM_DMA_LENGTH)
        QWORDMEMORYSET(18, BCM2836_PWM_CTRL_OFFSET, BCM2836_PWM_CTRL_LENGTH)
        QWORDBUSMEMORYSET(19, BCM2836_PWM_BUS_BASE_ADDRESS, BCM2836_PWM_BUS_LENGTH)
        QWORDBUSMEMORYSET(20, BCM2836_PWM_CTRL_UNCACHED_BASE_ADDRESS, BCM2836_PWM_CTRL_UNCACHED_LENGTH)
        QWORDMEMORYSET(21, BCM2836_PWM_CLK_OFFSET, BCM2836_PWM_CLK_LENGTH)

        // UART
        QWORDMEMORYSET(22, BCM2836_PL011_UART_OFFSET, BCM2836_PL011_UART_LENGTH)
        QWORDMEMORYSET(23, BCM2836_MINI_UART_OFFSET, BCM2836_MINI_UART_LENGTH)

        // SDC
        QWORDMEMORYSET(24, MMCHS1_OFFSET, MMCHS1_LENGTH)
        QWORDMEMORYSET(25, SDHOST_OFFSET, SDHOST_LENGTH)

        Return (RBUF)
      }

      Name (_DMA, ResourceTemplate() {
        //
        // Only the first GB is available.
        // Bus 0xC0000000 -> CPU 0x00000000.
        //
        QWordMemory (ResourceConsumer,
          ,
          MinFixed,
          MaxFixed,
          NonCacheable,
          ReadWrite,
          0x0,
          0x00000000C0000000, // MIN
          0x00000000FFFFFFFF, // MAX
          0xFFFFFFFF40000000, // TRA
          0x0000000040000000, // LEN
          ,
          ,
          )
      })
      include ("GpuDevs.asl")
    }

#if (RPI_MODEL == 4)
    // Lets start defining a thermal zone for the rpi
    // The idea here is we have the SOC temp (directly
    // or via the mailbox) as we flesh this out
    // move from basically setting some policies
    // and letting the OS poll the temp, to
    // allowing a GPIO to start/stop a fan,
    // or throttle the core via a mailbox.
    //
    // Define the thermal zone in _SB rather than _TZ
    // because we don't expect to need the backwards
    // compat on arm devices.
    //
    // We should also look at doing S4 (hibernate)
    // since we are now specifying a threshold for it
    Device(EC0)
    {
      Name(_HID, EISAID("PNP0C09"))
      Name (_CCA, 0x0)            // _CCA: make sure access are treated as uncached
      // Name(_GPE, 0)  //No GPE, lets use poll mode

      // Describe a fan
      PowerResource(PFAN, 0, 0) {
        OperationRegion (GPIO, SystemMemory, GPIO_BASE_ADDRESS, 0x1000)
        Field (GPIO, DWordAcc, NoLock, Preserve) {
          Offset(0x1C),
          GPS0, 32,
          GPS1, 32,
          RES1, 32,
          GPC0, 32,
          GPC1, 32,
          RES2, 32,
          GPL1, 32,
          GPL2, 32
        }
        // We are hitting a GPIO pin to on/off the fan
        // this assumes that uefi has programmed the
        // direction as OUT
        // Funny things will probably happen if
        // a pin controller starts up in linux/etc and
        // starts messing with it
        Method (_STA) {
          if ( GPL1 & (1 << GPIO_PIN) ) {
            Return ( 1 )               // present and enabled
          }
          Return ( 0 )
        }
        Method (_ON)  {                //if user defined a fan enable it
          Store((1 << GPIO_PIN), GPS0)
        }
        Method (_OFF) {                //disable it
          Store((1 << GPIO_PIN), GPC0)
        }
      }
      Device(FAN) {
        // Note, not currently an ACPIv4 fan
        // the latter adds speed control/detection
        // but in the case of linux needs FIF, FPS, FSL, and FST
        Name(_HID, EISAID("PNP0C0B"))
        Name(_PR0, Package() {PFAN})
      }

      // all temps in are tenths of K (aka 2732 is the min temps in linux (aka 0C))
      ThermalZone(TZ0) {
        Method(_TMP, 0, Serialized) {  // return current temp 0x7d5d2200 (thats the DT, need fd5d)
          OperationRegion (TEMS, SystemMemory, 0xfd5d2200, 0x8)
          Field (TEMS, DWordAcc, NoLock, Preserve) {
            TMPS, 32
          }
          return (((419949 - ((TMPS & 0x3ff) * 487)) / 100) + 2732);
        }
        Method(_SCP, 3) { }              // receive cooling policy from OS

        Method(_CRT) { return(3732) }    // (100K) Critical temp point (read from mailbox, causes immediate shutdown)
        Method(_HOT) { return(3632) }    // (90K) HOT state where OS should be trying to hibernate to protect the system (usually caused by some kind of active cooling failure (think AC failure, or just being in a desert) where PSV can't keep it cool)
        Method(_PSV) { return(3532) }    // (80K) (Pasive cooling (cpu throttling) trip point
                                         // Add additional _ACX's here if there are multiple fans/etc (ex: chassis vs cpu)
        Method(_AC0) { return(3332) }    // (60K) (active cooling trip point, if this is lower than PSV then we prefer active cooling, if the user sets up a fan then lets assure this is lower

        Name(_TZP, 10)                   //The OSPM must poll this device every 1 seconds
        Name(_AL0, Package(){\_SB.EC0.FAN}) // the fan used for AC0 above
        Name(_PSL, Package(){\_SB_.CPU0, \_SB_.CPU1, \_SB_.CPU2, \_SB_.CPU3})
      }
    }

    Device (ETH0)
    {
      Name (_HID, "BCM6E4E")
      Name (_CID, "BCM6E4E")
      Name (_UID, 0x0)
      Name (_CCA, 0x0)
      Method (_STA)
      {
        Return (0xf)
      }
      Method (_CRS, 0x0, Serialized)
      {
        Name (RBUF, ResourceTemplate ()
        {
          // No need for MEMORY32SETBASE on Genet as we have a straight base address constant
          MEMORY32FIXED (ReadWrite, GENET_BASE_ADDRESS, GENET_LENGTH, )
          Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive) { GENET_INTERRUPT0, GENET_INTERRUPT1 }
        })
        Return (RBUF)
      }
      Name (_DSD, Package () {
        ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
        Package () {
          Package () { "brcm,max-dma-burst-size", 0x08 },
          Package () { "phy-mode", "rgmii-rxid" },
        }
      })
    }
#endif

  }
}
