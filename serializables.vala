/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;

namespace Netsukuku.Hooking
{
    /* TODO
    serializable class NetworkData:
        int64 network_id
        List<int> gsizes
        int neighbor_n_nodes
        List<int> neighbor_pos
    */

    /* TODO
    serializable class EvaluateEnterData:
        int64 network_id
        List<int> neighbor_pos
        int min_lvl
        int evaluate_enter_id
    */

    /* TODO
    serializable class EvaluateEnterResult:
        int first_ask_lvl
        bool ask_again_error
        bool ignore_network_error
    */

    /* TODO
    serializable class BeginEnterData:
    */

    /* TODO
    serializable class BeginEnterResult:
        bool already_entering_error
    */

    /* TODO
    serializable class CompletedEnterData:
    */

    /* TODO
    serializable class CompletedEnterResult:
    */

    /* TODO
    serializable class AbortEnterData:
    */

    /* TODO
    serializable class AbortEnterResult:
    */

    public class EntryData : Object
    {
        public int64 network_id {get; set;}
        public Gee.List<int> pos {get; set;}
        public Gee.List<int> elderships {get; set;}

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "pos":
            case "elderships":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "network_id":
            case "network-id":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "pos":
            case "elderships":
                return serialize_list_int((Gee.List<int>)@value);
            case "network_id":
            case "network-id":
                return serialize_int((int)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    /* TODO
    serializable class PrepareEnterData:
        int enter_id
    */

    /* TODO
    serializable class FinishEnterData:
        int enter_id
        EntryData entry_data
        int go_connectivity_position
    */

    /* TODO
    serializable class PrepareMigrationData:
        int migration_id
    */

    /* TODO
    serializable class FinishMigrationData:
        int migration_id
        ... TODO
    */

    internal errordomain HelperDeserializeError {
        GENERIC
    }

    internal Object? deserialize_object(Type expected_type, bool nullable, Json.Node property_node)
    throws HelperDeserializeError
    {
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
        {
            if (!nullable)
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            return null;
        }
        if (!r.is_object())
            throw new HelperDeserializeError.GENERIC("element must be an object");
        string typename;
        if (!r.read_member("typename"))
            throw new HelperDeserializeError.GENERIC("element must have typename");
        if (!r.is_value())
            throw new HelperDeserializeError.GENERIC("typename must be a string");
        if (r.get_value().get_value_type() != typeof(string))
            throw new HelperDeserializeError.GENERIC("typename must be a string");
        typename = r.get_string_value();
        r.end_member();
        Type type = Type.from_name(typename);
        if (type == 0)
            throw new HelperDeserializeError.GENERIC(@"typename '$(typename)' unknown class");
        if (!type.is_a(expected_type))
            throw new HelperDeserializeError.GENERIC(@"typename '$(typename)' is not a '$(expected_type.name())'");
        if (!r.read_member("value"))
            throw new HelperDeserializeError.GENERIC("element must have value");
        r.end_member();
        unowned Json.Node p_value = property_node.get_object().get_member("value");
        Json.Node cp_value = p_value.copy();
        return Json.gobject_deserialize(type, cp_value);
    }

    internal Json.Node serialize_object(Object? obj)
    {
        if (obj == null) return new Json.Node(Json.NodeType.NULL);
        Json.Builder b = new Json.Builder();
        b.begin_object();
        b.set_member_name("typename");
        b.add_string_value(obj.get_type().name());
        b.set_member_name("value");
        Json.Node * obj_n = Json.gobject_serialize(obj);
        // json_builder_add_value docs says: The builder will take ownership of the #JsonNode.
        // but the vapi does not specify that the formal parameter is owned.
        // So I try and handle myself the unref of obj_n
        b.add_value(obj_n);
        b.end_object();
        return b.get_root();
    }

    internal class ListDeserializer<T> : Object
    {
        internal Gee.List<T> deserialize_list_object(Json.Node property_node)
        throws HelperDeserializeError
        {
            ArrayList<T> ret = new ArrayList<T>();
            Json.Reader r = new Json.Reader(property_node.copy());
            if (r.get_null_value())
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            if (!r.is_array())
                throw new HelperDeserializeError.GENERIC("element must be an array");
            int l = r.count_elements();
            for (uint j = 0; j < l; j++)
            {
                unowned Json.Node p_value = property_node.get_array().get_element(j);
                Json.Node cp_value = p_value.copy();
                ret.add(deserialize_object(typeof(T), false, cp_value));
            }
            return ret;
        }
    }

    internal Gee.List<Object> deserialize_list_object(Json.Node property_node)
    throws HelperDeserializeError
    {
        ListDeserializer<Object> c = new ListDeserializer<Object>();
        return c.deserialize_list_object(property_node);
    }

    internal Json.Node serialize_list_object(Gee.List<Object> lst)
    {
        Json.Builder b = new Json.Builder();
        b.begin_array();
        foreach (Object obj in lst)
        {
            b.begin_object();
            b.set_member_name("typename");
            b.add_string_value(obj.get_type().name());
            b.set_member_name("value");
            Json.Node * obj_n = Json.gobject_serialize(obj);
            // json_builder_add_value docs says: The builder will take ownership of the #JsonNode.
            // but the vapi does not specify that the formal parameter is owned.
            // So I try and handle myself the unref of obj_n
            b.add_value(obj_n);
            b.end_object();
        }
        b.end_array();
        return b.get_root();
    }

    internal int deserialize_int(Json.Node property_node)
    throws HelperDeserializeError
    {
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
            throw new HelperDeserializeError.GENERIC("element is not nullable");
        if (!r.is_value())
            throw new HelperDeserializeError.GENERIC("element must be a int");
        if (r.get_value().get_value_type() != typeof(int64))
            throw new HelperDeserializeError.GENERIC("element must be a int");
        int64 val = r.get_int_value();
        if (val > int.MAX || val < int.MIN)
            throw new HelperDeserializeError.GENERIC("element overflows size of int");
        return (int)val;
    }

    internal Json.Node serialize_int(int i)
    {
        Json.Node ret = new Json.Node(Json.NodeType.VALUE);
        ret.set_int(i);
        return ret;
    }

    internal Gee.List<int> deserialize_list_int(Json.Node property_node)
    throws HelperDeserializeError
    {
        ArrayList<int> ret = new ArrayList<int>();
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
            throw new HelperDeserializeError.GENERIC("element is not nullable");
        if (!r.is_array())
            throw new HelperDeserializeError.GENERIC("element must be an array");
        int l = r.count_elements();
        for (int j = 0; j < l; j++)
        {
            r.read_element(j);
            if (r.get_null_value())
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            if (!r.is_value())
                throw new HelperDeserializeError.GENERIC("element must be a int");
            if (r.get_value().get_value_type() != typeof(int64))
                throw new HelperDeserializeError.GENERIC("element must be a int");
            int64 val = r.get_int_value();
            if (val > int.MAX || val < int.MIN)
                throw new HelperDeserializeError.GENERIC("element overflows size of int");
            ret.add((int)val);
            r.end_element();
        }
        return ret;
    }

    internal Json.Node serialize_list_int(Gee.List<int> lst)
    {
        Json.Builder b = new Json.Builder();
        b.begin_array();
        foreach (int i in lst)
        {
            b.add_int_value(i);
        }
        b.end_array();
        return b.get_root();
    }
}
