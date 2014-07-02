-----------------------------------------------------------------------
--  util-dates-formats-tests - Test for date formats
--  Copyright (C) 2011, 2013, 2014 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

with Util.Tests;
package Util.Dates.Formats.Tests is

   procedure Add_Tests (Suite : in Util.Tests.Access_Test_Suite);

   type Test is new Util.Tests.Test with null record;

   procedure Test_Format (T : in out Test);

   --  Test the Get_Day_Start operation.
   procedure Test_Get_Day_Start (T : in out Test);

   --  Test the Get_Week_Start operation.
   procedure Test_Get_Week_Start (T : in out Test);

   --  Test the Get_Month_Start operation.
   procedure Test_Get_Month_Start (T : in out Test);

   --  Test the Get_Day_End operation.
   procedure Test_Get_Day_End (T : in out Test);

   --  Test the Get_Week_End operation.
   procedure Test_Get_Week_End (T : in out Test);

   --  Test the Get_Month_End operation.
   procedure Test_Get_Month_End (T : in out Test);

   --  Test the Split operation.
   procedure Test_Split (T : in out Test);

end Util.Dates.Formats.Tests;
