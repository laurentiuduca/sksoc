/****************************************************************************
 * apps/testing/ostest/robust.c
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 ****************************************************************************/

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>

#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <debug.h>
#include <time.h>
#include <unistd.h>

#include "ostest.h"

/****************************************************************************
 * Private Data
 ****************************************************************************/

static pthread_mutex_t g_robust_mutex;

/****************************************************************************
 * Private Functions
 ****************************************************************************/

static FAR void *robust_waiter(FAR void *parameter)
{
  int status;

  /* Take the mutex */

  _info("robust_waiter: Taking mutex\n");
  status = pthread_mutex_lock(&g_robust_mutex);
  if (status != 0)
    {
       _info("thread_waiter: ERROR: pthread_mutex_lock failed, status=%d\n",
               status);
       ASSERT(false);
    }

  if (status != 0)
    {
       _info("robust_waiter: ERROR: pthread_mutex_lock failed, status=%d\n",
               status);
       ASSERT(false);
    }
  else
    {
      _info("robust_waiter: Exiting with mutex\n");
    }

  usleep(2);
  return NULL;
}

/****************************************************************************
 * Public Functions
 ****************************************************************************/

void robust_test(void)
{
  pthread_attr_t pattr;
  pthread_mutexattr_t mattr;
  pthread_t waiter;
  void *result;
  int nerrors = 0;
  int status;

  /* Initialize the mutex */

  _info("robust_test: Initializing mutex\n");

  status = pthread_mutexattr_init(&mattr);
  if (status != 0)
    {
      _info("robust_test: ERROR: "
             "pthread_mutexattr_init failed, status=%d\n",
             status);
      ASSERT(false);
      nerrors++;
    }

  status = pthread_mutexattr_setrobust(&mattr, PTHREAD_MUTEX_ROBUST);
  if (status != 0)
    {
      _info("robust_test: ERROR: "
             "pthread_mutexattr_setrobust failed, status=%d\n",
             status);
      ASSERT(false);
      nerrors++;
    }

  status = pthread_mutex_init(&g_robust_mutex, &mattr);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_mutex_init failed, status=%d\n",
             status);
      ASSERT(false);
      nerrors++;
    }

  /* Set up pthread attributes */

  _info("robust_test: Starting thread\n");

  status = pthread_attr_init(&pattr);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_attr_init failed, status=%d\n",
             status);
      ASSERT(false);
      nerrors++;
    }

  status = pthread_attr_setstacksize(&pattr, STACKSIZE);
  if (status != 0)
    {
      _info("robust_test: ERROR: "
             "pthread_attr_setstacksize failed, status=%d\n",
             status);
      ASSERT(false);
      nerrors++;
    }

  /* Start the robust waiter thread.  It will take the mutex, usleep for two
   * seconds, and exit holding the mutex.
   */

  status = pthread_create(&waiter, &pattr, robust_waiter, NULL);
  if (status != 0)
    {
      _info("robust_test: ERROR: "
             "pthread_create failed, status=%d\n", status);
      _info("             ERROR: Terminating test\n");
      ASSERT(false);
      nerrors++;
      return;
    }

  /* Wait one second.. the robust waiter should still be waiting */

  usleep(1);

  /* Now try to take the mutex held by the robust waiter.  This should wait
   * one second there fail with EOWNERDEAD.
   */

  status = pthread_mutex_lock(&g_robust_mutex);
  if (status == 0)
    {
      _info("robust_test: ERROR: pthread_mutex_lock succeeded\n");
      ASSERT(false);
      nerrors++;
    }
  else if (status != EOWNERDEAD)
    {
      _info("robust_test: ERROR: pthread_mutex_lock failed with %d\n",
              status);
      _info("             ERROR: expected %d (EOWNERDEAD)\n", EOWNERDEAD);
      ASSERT(false);
      nerrors++;
    }

  /* Try again,
   * this should return immediately, still failing with EOWNERDEAD
   */

  _info("robust_test: Take the lock again\n");
  status = pthread_mutex_lock(&g_robust_mutex);
  if (status == 0)
    {
      _info("robust_test: ERROR: pthread_mutex_lock succeeded\n");
      ASSERT(false);
      nerrors++;
    }
  else if (status != EOWNERDEAD)
    {
      _info("robust_test: ERROR: pthread_mutex_lock failed with %d\n",
              status);
      _info("             ERROR: expected %d (EOWNERDEAD)\n", EOWNERDEAD);
      ASSERT(false);
      nerrors++;
    }

  /* Make sure waiter exit completely */

  do
    {
      usleep(1);
    }
  while (kill(waiter, 0) == 0 || errno != ESRCH);

  /* Make the mutex consistent and try again.  It should succeed this time. */

  _info("robust_test: Make the mutex consistent again.\n");
  status = pthread_mutex_consistent(&g_robust_mutex);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_mutex_consistent failed: %d\n",
              status);
      ASSERT(false);
      nerrors++;
    }

  _info("robust_test: Take the lock again\n");
  status = pthread_mutex_lock(&g_robust_mutex);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_mutex_lock failed with: %d\n",
              status);
      ASSERT(false);
      nerrors++;
    }

  /* Then join to the thread to pick up the result (if we don't do this we
   * will have a memory leak!)
   */

  _info("robust_test: Joining\n");
  status = pthread_join(waiter, &result);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_join failed, status=%d\n", status);
      ASSERT(false);
      nerrors++;
    }
  else
    {
      _info("robust_test: waiter exited with result=%p\n", result);
      if (result != NULL)
        {
          _info("robust_test: ERROR: expected result=%p\n",
                  PTHREAD_CANCELED);
          ASSERT(false);
          nerrors++;
        }
    }

  /* Release and destroy the mutex then  return success */

  status = pthread_mutex_unlock(&g_robust_mutex);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_mutex_unlock failed, status=%d\n",
              status);
      ASSERT(false);
      nerrors++;
    }

  status = pthread_mutex_destroy(&g_robust_mutex);
  if (status != 0)
    {
      _info("robust_test: ERROR: pthread_mutex_unlock failed, status=%d\n",
              status);
      ASSERT(false);
      nerrors++;
    }

  _info("robust_test: Test complete with nerrors=%d\n", nerrors);
}
