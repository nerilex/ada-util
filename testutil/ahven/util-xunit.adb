-----------------------------------------------------------------------
--  AUnit utils - Helper for writing unit tests
--  Copyright (C) 2009, 2010, 2011 Stephane Carrez
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

--  with AUnit.Options;
--  with AUnit.Reporter.Text;
--  with AUnit.Run;

with Ada.Directories;
with Ada.Calendar.Formatting;

with Ahven.XML_Runner;
with Ahven.Text_Runner;

with Util.Files;
--  with Util.Tests.Reporter;
package body Util.XUnit is

--     use AUnit.Assertions;

   function Format (S : in String) return Message_String is
   begin
      return S;
   end Format;

   function Build_Message (Message   : in String;
                           Source    : in String;
                           Line      : in Natural) return String is
      L : constant String := Natural'Image (Line);
   begin
      return Source & ":" & L (2 .. L'Last) & ": " & Message;
   end Build_Message;

   --  ------------------------------
   --  Check that the value matches what we expect.
   --  ------------------------------
   --     procedure Assert_Equals (T       : in AUnit.Assertions.Test'Class;
   --                              Expect, Value : in Integer;
   --                              Message : in String := "Test failed";
   --                              Source    : String := GNAT.Source_Info.File;
   --                              Line      : Natural := GNAT.Source_Info.Line) is
   --     begin
   --        T.Assert (Condition => Expect = Value,
   --                  Message   => Message & ": expecting '"
   --                  & Integer'Image (Expect) & "'"
   --                  & " value was '"
   --                  & Integer'Image (Value) & "'",
   --                  Source    => Source,
   --                  Line      => Line);
   --     end Assert_Equals;

   --  ------------------------------
   --  Check that the value matches what we expect.
   --  ------------------------------
   procedure Assert (T         : in Test;
                     Condition : in Boolean;
                     Message   : in String := "Test failed";
                     Source    : String := GNAT.Source_Info.File;
                     Line      : Natural := GNAT.Source_Info.Line) is
      pragma Unreferenced (T);
   begin
      Ahven.Assert (Condition => Condition,
                    Message   => Build_Message (Message => Message,
                                                Source  => Source,
                                                Line    => Line));
   end Assert;

   --  ------------------------------
   --  Check that the value matches what we expect.
   --  ------------------------------
   procedure Assert_Equals (T         : in Test'Class;
                            Expect, Value : in Ada.Calendar.Time;
                            Message   : in String := "Test failed";
                            Source    : String := GNAT.Source_Info.File;
                            Line      : Natural := GNAT.Source_Info.Line) is
      use Ada.Calendar.Formatting;
      use Ada.Calendar;
   begin
      T.Assert (Condition => Image (Expect) = Image (Value),
                Message   => Message & ": expecting '" & Image (Expect) & "'"
                & " value was '" & Image (Value) & "'",
                Source    => Source,
                Line      => Line);
   end Assert_Equals;

   --  ------------------------------
   --  Check that the value matches what we expect.
   --  ------------------------------
   procedure Assert_Equals (T         : in Test'Class;
                            Expect, Value : in String;
                            Message   : in String := "Test failed";
                            Source    : String := GNAT.Source_Info.File;
                            Line      : Natural := GNAT.Source_Info.Line) is
   begin
      T.Assert (Condition => Expect = Value,
                Message   => Message & ": expecting '" & Expect & "'"
                & " value was '" & Value & "'",
                Source    => Source,
                Line      => Line);
   end Assert_Equals;

   --  ------------------------------
   --  Check that the value matches what we expect.
   --  ------------------------------
   procedure Assert_Equals (T       : in Test'Class;
                            Expect  : in String;
                            Value   : in Unbounded_String;
                            Message : in String := "Test failed";
                            Source  : String := GNAT.Source_Info.File;
                            Line    : Natural := GNAT.Source_Info.Line) is
   begin
      Assert_Equals (T      => T,
                     Expect => Expect,
                     Value  => To_String (Value),
                     Message => Message,
                     Source  => Source,
                     Line    => Line);
   end Assert_Equals;

   --  ------------------------------
   --  Check that two files are equal.  This is intended to be used by
   --  tests that create files that are then checked against patterns.
   --  ------------------------------
   procedure Assert_Equal_Files (T       : in Test'Class;
                                 Expect  : in String;
                                 Test    : in String;
                                 Message : in String := "Test failed";
                                 Source  : String := GNAT.Source_Info.File;
                                 Line    : Natural := GNAT.Source_Info.Line) is
      use Util.Files;

      Expect_File : Unbounded_String;
      Test_File   : Unbounded_String;
      Same        : Boolean;
   begin
      begin
         if not Ada.Directories.Exists (Expect) then
            T.Assert (False, "Expect file '" & Expect & "' does not exist",
                      Source => Source, Line => Line);
         end if;
         Read_File (Path => Expect,
                    Into => Expect_File);
         Read_File (Path => Test,
                    Into => Test_File);

      exception
         when others =>
            --              if Update_Test_Files then
            --                 Ada.Directories.Copy_File (Source_Name => Test,
            --                                            Target_Name => Expect);
            --              end if;
            null;
      end;

      --  Check file sizes
      Assert_Equals (T       => T,
                     Expect  => Length (Expect_File),
                     Value   => Length (Test_File),
                     Message => Message & ": Invalid file sizes",
                     Source  => Source,
                     Line    => Line);

      Same := Expect_File = Test_File;
      if Same then
         return;
      end if;
   end Assert_Equal_Files;

   First_Test : Test_Object_Access := null;

   procedure Register (T : in Test_Object_Access) is
   begin
      T.Next := First_Test;
      First_Test := T;
   end Register;

   --  ------------------------------
   --  The main testsuite program.  This launches the tests, collects the
   --  results, create performance logs and set the program exit status
   --  according to the testsuite execution status.
   --  ------------------------------
   procedure Harness (Output : in Ada.Strings.Unbounded.Unbounded_String;
                      XML    : in Boolean;
                      Result : out Status) is

      Tests : constant Access_Test_Suite := Suite;
      T     : Test_Object_Access := First_Test;
--        O  : AUnit.Options.AUnit_Options := AUnit.Options.Default_Options;
   begin
      while T /= null loop
         Ahven.Framework.Add_Static_Test (Tests.all, T.Test.all);
         T := T.Next;
      end loop;

--        O.Global_Timer    := True;
--        O.Test_Case_Timer := True;
      if XML then
--           declare
--              Reporter : Util.Tests.Reporter.XML_Reporter;
         begin
--              Reporter.File := Output;
            Ahven.Text_Runner.Run (Tests.all);
            --              Result := Runner (Reporter, O);
            Result := Success;
         end;
      else
--           declare
--              Reporter : AUnit.Reporter.Text.Text_Reporter;
         begin
            Ahven.XML_Runner.Run (Tests.all);
            Result := Success;
--              Result := Runner (Reporter, O);
         end;
      end if;
   end Harness;

end Util.XUnit;