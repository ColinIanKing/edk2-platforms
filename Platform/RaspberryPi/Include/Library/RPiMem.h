/** @file
 *
 *  Copyright (c) 2019, Pete Batard <pete@akeo.ie>
 *
 *  SPDX-License-Identifier: BSD-2-Clause-Patent
 *
 **/

#ifndef __RPI_MEM_H__
#define __RPI_MEM_H__

#define RPI_MEM_BASIC_REGION    0
#define RPI_MEM_RUNTIME_REGION  1
#define RPI_MEM_RESERVED_REGION 2 

typedef struct {
  CONST CHAR16*                 Name;
  UINTN                         Type;
} RPI_MEMORY_REGION_INFO;

VOID
RpiPlatformGetVirtualMemoryInfo (
  IN RPI_MEMORY_REGION_INFO** MemoryInfo
  );

#endif /* __RPI_MEM_H__ */
