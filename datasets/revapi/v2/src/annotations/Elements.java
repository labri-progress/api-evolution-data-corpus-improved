/*
 * Copyright 2014-2017 Lukas Krejci
 * and other contributors as indicated by the @author tags.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Target;

public class Elements {

    @Target({ElementType.ANNOTATION_TYPE, ElementType.CONSTRUCTOR, ElementType.FIELD, ElementType.METHOD,
            ElementType.PARAMETER, ElementType.TYPE, ElementType.TYPE_PARAMETER, ElementType.TYPE_USE})
    public @interface Anno {

    }

    @Anno
    public static class TestClass<@Anno T extends @Anno Cloneable> {

        @Anno
        public <@Anno X extends @Anno String> int method(@Anno int param1, @Anno java.util.Map<@Anno X, @Anno String> param2) {
            return 0;
        }
    }
}
