-----------------------------------------------------------------------
--  Util-texts -- Various Text Transformation Utilities
--  Copyright (C) 2001, 2002, 2003, 2009, 2010 Stephane Carrez
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
package body Util.Texts.Transforms is

   type Code is mod 2**32;

   procedure Put_Hex (Into : in out Stream; Value : Code) is
      Conversion : constant String (1 .. 16) := "0123456789ABCDEF";
      S          : String (1 .. 6) := (1 => '\', 2 => 'u', others => '0');
      P          : Code := Value;
      N          : Code;
      I          : Positive := S'Last;
   begin
      while P /= 0 loop
         N := P mod 16;
         P := P / 16;
         S (I) := Conversion (Positive'Val (N + 1));
         exit when I = 1;
         I := I - 1;
      end loop;
      for J in S'Range loop
         Put (Into, S (J));
      end loop;
   end Put_Hex;

   --  ------------------------------
   --  Capitalize the string into the result stream.
   --  ------------------------------
   procedure Capitalize (Content : in Input;
                         Into    : in out Stream) is
      Upper  : Boolean := True;
      C      : Code;
   begin
      for I in Content'Range loop
         if Upper then
            C := Char'Pos (To_Upper (Content (I)));
            Upper := False;
         else
            C := Char'Pos (To_Lower (Content (I)));
            if C = Character'Pos ('_') then
               Upper := True;
            end if;
         end if;
         Put (Into, Character'Val (C));
      end loop;
   end Capitalize;

   --  ------------------------------
   --  Capitalize the string
   --  ------------------------------
   function Capitalize (Content : Input) return Input is
      Result : Stream;
   begin
      Capitalize (Content, Result);
      return To_Input (Result);
   end Capitalize;

   --  ------------------------------
   --  Translate the input string into an upper case string in the result stream.
   --  ------------------------------
   procedure To_Upper_Case (Content : in Input;
                            Into    : in out Stream) is
      C      : Code;
   begin
      for I in Content'Range loop
         C := Char'Pos (To_Upper (Content (I)));
         Put (Into, Character'Val (C));
      end loop;
   end To_Upper_Case;

   --  ------------------------------
   --  Translate the input string into an upper case string.
   --  ------------------------------
   function To_Upper_Case (Content : Input) return Input is
      Result : Input (Content'Range);
   begin
      for I in Content'Range loop
         Result (I) := To_Upper (Content (I));
      end loop;
      return Result;
   end To_Upper_Case;

   --  ------------------------------
   --  Translate the input string into a lower case string in the result stream.
   --  ------------------------------
   procedure To_Lower_Case (Content : in Input;
                            Into    : in out Stream) is
      C      : Code;
   begin
      for I in Content'Range loop
         C := Char'Pos (To_Lower (Content (I)));
         Put (Into, Character'Val (C));
      end loop;
   end To_Lower_Case;

   --  ------------------------------
   --  Translate the input string into a lower case string in the result stream.
   --  ------------------------------
   function To_Lower_Case (Content : Input) return Input is
      Result : Input (Content'Range);
   begin
      for I in Content'Range loop
         Result (I) := To_Lower (Content (I));
      end loop;
      return Result;
   end To_Lower_Case;

   procedure Escape_Java_Script (Content : in Input;
                                 Into    : in out Stream) is
   begin
      Escape_Java (Content             => Content, Into => Into,
                   Escape_Single_Quote => True);
   end Escape_Java_Script;

   function Escape_Java_Script (Content : Input) return Input is
      Result : Stream;
   begin
      Escape_Java (Content             => Content,
                   Into                => Result,
                   Escape_Single_Quote => True);
      return To_Input (Result);
   end Escape_Java_Script;

   procedure Escape_Java (Content : in Input;
                          Into    : in out Stream) is
   begin
      Escape_Java (Content             => Content, Into => Into,
                   Escape_Single_Quote => False);
   end Escape_Java;
   function Escape_Java (Content : Input) return Input is
      Result : Stream;
   begin
      Escape_Java (Content             => Content,
                   Into                => Result,
                   Escape_Single_Quote => False);
      return To_Input (Result);
   end Escape_Java;

   procedure Escape_Java (Content             : in Input;
                          Escape_Single_Quote : in Boolean;
                          Into                : in out Stream) is
      C : Code;
   begin
      for I in Content'Range loop
         C := Char'Pos (Content (I));
         if C < 16#20# then
            if C = 16#0A# then
               Put (Into, '\');
               Put (Into, 'n');

            elsif C = 16#0D# then
               Put (Into, '\');
               Put (Into, 'r');

            elsif C = 16#08# then
               Put (Into, '\');
               Put (Into, 'b');

            elsif C = 16#09# then
               Put (Into, '\');
               Put (Into, 't');

            elsif C = 16#0C# then
               Put (Into, '\');
               Put (Into, 'f');
            else
               Put_Hex (Into, C);
            end if;

         elsif C = 16#27# then
            if Escape_Single_Quote then
               Put (Into, '\');
            end if;
            Put (Into, Character'Val (C));

         elsif C = 16#22# then
            Put (Into, '\');
            Put (Into, Character'Val (C));

         elsif C = 16#5C# then
            Put (Into, '\');
            Put (Into, Character'Val (C));

         elsif C > 16#80# then
            Put_Hex (Into, C);

         else
            Put (Into, Character'Val (C));
         end if;
      end loop;
   end Escape_Java;

end Util.Texts.Transforms;