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
package methods;

public abstract class Abstract {

    public abstract void abstractMethod();

    public void concreteMethod() {}

    private static abstract class PrivateSuperClass {

    }

    private static abstract class PubliclyUsedPrivateSuperClass {

    }

    public static class A extends PrivateSuperClass {

    }

    public static abstract class B extends PrivateSuperClass {
        public abstract PubliclyUsedPrivateSuperClass abstractMethod();
    }

    public static class C extends PubliclyUsedPrivateSuperClass {

    }
}
